//
//  TraceLog.h
//  CloudScope
//
//  Created by Tony Stone on 3/31/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#ifndef ResourceManager_TraceLog_h
#define ResourceManager_TraceLog_h

#import <Foundation/Foundation.h>

/*
 
 TraceLog allows you to set logging levels for all classes, all classes
 with a specific prefix or individual classes in your application.  
 It uses both the  preprocessor define DEBUG and environment variables 
 to specify what needs to be set.  
 
 To use, please set the preprocessor  directive DEUG (which should 
 already be set in the development scheme.  This turns the system on.  
 
 You can then set environment variables to set the logging levels 
 using the variable syntax below.
 
 NOTE: More specific scope overrides less specific scope.
       Here is the precedence for evaluation
 
       CLASS, PREFIX, ALL
 
 Environment Variables:

    LOG_CLASS_<CLASSNAME>=<LEVEL> 
    LOG_PREFIX_<CLASSPREFIX>=<LEVEL>
    LOG_ALL=<LEVEL>
 
 Levels:
 
    ERROR 
    WARNING
    INFO
    TRACE1
    TRACE2
    TRACE3
    TRACE4
 
 Examples:
 
    LOG_ALL=ERROR

    LOG_PREFIX_RM=TRACE1
 
    LOG_CLASS_RMLISTWEBSERVICE=ERROR
 
    LOG_CLASS_BTWEBSERVICEPROCESSOR=WARNING
    LOG_CLASS_BTSECURITYMANAGER=WARNING

 */

typedef enum {
    LogLevelNone    = 0,
    LogLevelError   = 1,
    LogLevelWarning = 2,
    LogLevelInfo    = 3,
    LogLevelTrace1  = 4,
    LogLevelTrace2  = 5,
    LogLevelTrace3  = 6,
    LogLevelTrace4  = 7
} LogLevel;

@interface MGTraceLog  : NSObject
// NOTE: You do not call this directly, please use the macros below
+ (void) logMessage: (Class) callingClass classInstance: (id) classInstance selector: (SEL) selector sourceFile: (const char *) sourceFile sourceLineNumber: (int) sourceLineNumber logLevel: (LogLevel) level message: (NSString *) message;
@end

#ifdef DEBUG

#define LogError(...)       [MGTraceLog logMessage: [self class] classInstance: self selector: _cmd sourceFile: __FILE__ sourceLineNumber: __LINE__ logLevel: LogLevelError   message: [NSString stringWithFormat:__VA_ARGS__]]
#define LogWarning(...)     [MGTraceLog logMessage: [self class] classInstance: self selector: _cmd sourceFile: __FILE__ sourceLineNumber: __LINE__ logLevel: LogLevelWarning message: [NSString stringWithFormat:__VA_ARGS__]]
#define LogInfo(...)        [MGTraceLog logMessage: [self class] classInstance: self selector: _cmd sourceFile: __FILE__ sourceLineNumber: __LINE__ logLevel: LogLevelInfo    message: [NSString stringWithFormat:__VA_ARGS__]]
#define LogTrace(level,...) [MGTraceLog logMessage: [self class] classInstance: self selector: _cmd sourceFile: __FILE__ sourceLineNumber: __LINE__ logLevel: LogLevelTrace1 + ((int)level) - 1   message: [NSString stringWithFormat:__VA_ARGS__]]


#else

#define LogError(...)   /* empty */
#define LogWarning(...) /* empty */
#define LogInfo(...)    /* empty */
#define LogTrace(1, ...)   /* empty */

#endif

#endif