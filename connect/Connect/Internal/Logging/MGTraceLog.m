//
//  TraceLog.m
//  CloudScope
//
//  Created by Tony Stone on 3/31/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import "MGTraceLog.h"

static NSString * const kLogScopeClass         = @"LOG_CLASS";
static NSString * const kLogScopePrefix        = @"LOG_PREFIX";
static NSString * const kLogScopeAll           = @"LOG_ALL";

static NSString * const kLogLevelErrorString   = @"ERROR";
static NSString * const kLogLevelWarningString = @"WARNING";
static NSString * const KLogLevelInfoString    = @"INFO";
static NSString * const KLogLevelTrace1String  = @"TRACE1";
static NSString * const KLogLevelTrace2String  = @"TRACE2";
static NSString * const KLogLevelTrace3String  = @"TRACE3";
static NSString * const KLogLevelTrace4String  = @"TRACE4";

static LogLevel       globalLogLevel;
static NSDictionary * loggedPrefixes;
static NSDictionary * loggedClasses;

@interface MGTraceLog ()
+ (LogLevel) logLevelForString: (NSString *) logLevelString;
+ (NSString *) stringForLogLevel: (LogLevel) logLevel;
@end

LogLevel logLevelForString(NSString * logLevelString);
NSString * stringForLogLevel(LogLevel logLevel);

@implementation MGTraceLog

+ (void)initialize {
    
    if (self == [MGTraceLog class]) {
        globalLogLevel = LogLevelNone;
        
        //
        // NOTE: we don't want to incure the overhead of the initialization 
        //       if debug is not defined and these methods are not going to
        //       be called.
        //
        
#ifdef DEBUG
        
        NSDictionary        * environmentVariables = [[NSProcessInfo processInfo] environment];
        NSMutableDictionary * tmpLoggedPrefixes    = [[NSMutableDictionary alloc] init];
        NSMutableDictionary * tmpLoggedClasses     = [[NSMutableDictionary alloc] init];
        
        for (NSString * variable in environmentVariables) {
            NSString * upperCaseVariable = [variable uppercaseString];
            
            NSString * logLevelString  = [environmentVariables objectForKey: variable]; 
            
            if ([upperCaseVariable hasPrefix: kLogScopeAll]) {
                
                globalLogLevel = [MGTraceLog logLevelForString: logLevelString];
                
            } else if ([upperCaseVariable hasPrefix: kLogScopePrefix]) {
                NSRange    logLevelScopeRange = [upperCaseVariable rangeOfString: kLogScopePrefix];
                NSString * logLevelScope      = [upperCaseVariable substringFromIndex: logLevelScopeRange.location + logLevelScopeRange.length + 1];
                
                [tmpLoggedPrefixes setObject: [NSNumber numberWithInt: [MGTraceLog logLevelForString: logLevelString]] forKey: logLevelScope];                
            } else if ([upperCaseVariable hasPrefix: kLogScopeClass]) {
                NSRange    logLevelScopeRange = [upperCaseVariable rangeOfString: kLogScopeClass];
                NSString * logLevelScope      = [upperCaseVariable substringFromIndex: logLevelScopeRange.location + logLevelScopeRange.length + 1];
                
                [tmpLoggedClasses setObject: [NSNumber numberWithInt: [MGTraceLog logLevelForString: logLevelString]] forKey: logLevelScope];                
            }
        }
        loggedPrefixes = [[NSDictionary alloc] initWithDictionary: tmpLoggedPrefixes];
        loggedClasses  = [[NSDictionary alloc] initWithDictionary: tmpLoggedClasses];
        
        //
        // We eat our own dog food here.  
        //
        // Log respects the log settings that have been set for 
        // itself as well.
        //
        LogInfo(@"DEBUG is enabled");
        
        NSMutableString * loggedString = [[NSMutableString alloc] init];
        
        if ([loggedClasses count] > 0) {
            
            [loggedString appendString: @"\n\tclass: {\n"];
            
            for (NSString  * className in [loggedClasses allKeys]) {
                NSNumber  * logLevel = [loggedClasses objectForKey: className];
                
                [loggedString appendString: [[NSMutableString alloc] initWithFormat: @"\n%30s=%@", [className UTF8String], [self stringForLogLevel: [logLevel intValue]]]];
            }
            [loggedString appendString: @"\n\t}"];
        }
        
        if ([loggedPrefixes count] > 0) {
            
            [loggedString appendString: @"\n\tprefix: {\n"];
            
            for (NSString  * prefix in [loggedPrefixes allKeys]) {
                NSNumber  * logLevel = [loggedPrefixes objectForKey: prefix];
                
                [loggedString appendString: [[NSMutableString alloc] initWithFormat: @"\n%30s=%@", [prefix UTF8String], [self stringForLogLevel: [logLevel intValue]]]];
            }
            [loggedString appendString: @"\n\t}"];
        }
        
        
        
        [loggedString appendFormat: @"\n\tglobal: {\n\n%30s=%@\n\t}", "ALL", [self stringForLogLevel: globalLogLevel]];
        
        LogInfo(@"Log level settigs: \n{%@\n}", loggedString);
#endif
    }
}

+ (LogLevel) logLevelForString: (NSString *) logLevelString {
    
    if      ([[logLevelString uppercaseString] isEqualToString: kLogLevelErrorString])    return LogLevelError;
    else if ([[logLevelString uppercaseString] isEqualToString: kLogLevelWarningString])  return LogLevelWarning;
    else if ([[logLevelString uppercaseString] isEqualToString: KLogLevelInfoString])     return LogLevelInfo;
    else if ([[logLevelString uppercaseString] isEqualToString: KLogLevelTrace1String])   return LogLevelTrace1;
    else if ([[logLevelString uppercaseString] isEqualToString: KLogLevelTrace2String])   return LogLevelTrace2;
    else if ([[logLevelString uppercaseString] isEqualToString: KLogLevelTrace3String])   return LogLevelTrace3;
    else if ([[logLevelString uppercaseString] isEqualToString: KLogLevelTrace4String])   return LogLevelTrace4;

    
    return LogLevelNone;
}

+ (NSString *) stringForLogLevel: (LogLevel) logLevel {
    
    switch (logLevel) {
        case LogLevelError:   return kLogLevelErrorString;
        case LogLevelWarning: return kLogLevelWarningString;
        case LogLevelInfo:    return KLogLevelInfoString;
        case LogLevelTrace1:  return KLogLevelTrace1String;
        case LogLevelTrace2:  return KLogLevelTrace2String;
        case LogLevelTrace3:  return KLogLevelTrace3String;
        case LogLevelTrace4:  return KLogLevelTrace4String;
            
        default:              return @"OFF";
    }
}

+ (NSNumber *) prefixLogLevel: (NSString *) className {
    
    for (NSString * prefix in [loggedPrefixes allKeys]) {
        if ([className hasPrefix: prefix]) {
            NSNumber * level = [loggedPrefixes objectForKey: prefix];
            
            return level;
        }
    }
    return nil;
}

+ (void) logMessage: (Class) callingClass classInstance: (id) classInstance selector: (SEL) selector sourceFile: (const char *) sourceFile sourceLineNumber: (int) sourceLineNumber logLevel: (LogLevel) level message: (NSString *) message {
    NSString * className      = [NSStringFromClass(callingClass) uppercaseString];
    NSNumber * classLogLevel  = [loggedClasses objectForKey: className];
    NSNumber * prefixLogLevel = [self prefixLogLevel: className];
    
    // Defaults to global level
    LogLevel currentLevel = globalLogLevel;
    
    //
    // NOTE: We take the most specific first which
    //       overrides less specific 
    //
    if (classLogLevel) {
        currentLevel = [classLogLevel intValue];
    } else if (prefixLogLevel) {
        currentLevel = [prefixLogLevel intValue];
    }
    
    if (currentLevel >= level) {
        NSLog(@"%7s: <%@ : %p> %@", [[MGTraceLog stringForLogLevel: level] cStringUsingEncoding: NSUTF8StringEncoding], NSStringFromClass(callingClass), classInstance, message);
    } 
}

@end



