//
// Created by Tony Stone on 7/14/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGMessageLog.h"

@implementation MGMessageLog {
        NSMutableSet * _registeredListeners;
    }
    static MGMessageLog *_instance = nil;

    + (void) load {
        if (_instance == nil) {
            _instance = [[MGMessageLog alloc] init];
        }
    }

    + (MGMessageLog *)instance {
        return _instance;
    }

    - (instancetype)init {
        self = [super init];
        if (self) {
            _registeredListeners = [[NSMutableSet alloc] init];
        }
        return self;
    }

    - (void)registerListener:(id <MGMessageLogListener>)object {
        [_registeredListeners addObject: object];
    }

    - (void)unregisterListener:(id <MGMessageLogListener>)object {
        [_registeredListeners removeObject: object];
    }

    - (void)logError:(NSString *)format, ... {
        if (_registeredListeners) {
            va_list args;
            va_start(args, format);
            NSMutableString * string = [[NSMutableString alloc] initWithFormat: format arguments: args];
            va_end(args);

           for (id <MGMessageLogListener> listener in _registeredListeners) {
               [listener didReceiveError: string];
           }
        }
    }

    - (void)logWarning:(NSString *)format, ... {
        if (_registeredListeners) {
            va_list args;
            va_start(args, format);
            NSMutableString * string = [[NSMutableString alloc] initWithFormat: format arguments: args];
            va_end(args);

            for (id <MGMessageLogListener> listener in _registeredListeners) {
                [listener didReceiveWarning: string];
            }
        }
    }

    - (void)logInfo:(NSString *)format, ... {
        if (_registeredListeners) {
            va_list args;
            va_start(args, format);
            NSMutableString * string = [[NSMutableString alloc] initWithFormat: format arguments: args];
            va_end(args);

            for (id <MGMessageLogListener> listener in _registeredListeners) {
                [listener didReceiveInfo: string];
            }
        }
    }



@end