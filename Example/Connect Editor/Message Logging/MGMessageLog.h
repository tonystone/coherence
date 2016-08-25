//
// Created by Tony Stone on 7/14/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MGMessageLogListener

    @required
        - (void) didReceiveError: (NSString *) string;
        - (void) didReceiveWarning: (NSString *) string;
        - (void) didReceiveInfo: (NSString *) string;
@end


@interface MGMessageLog : NSObject

    + (MGMessageLog *)instance;

    - (void) logError: (NSString *) format,...;
    - (void) logWarning: (NSString *) format,...;
    - (void) logInfo: (NSString *) format,...;

    - (void) registerListener: (id <MGMessageLogListener>) object;
    - (void) unregisterListener: (id <MGMessageLogListener>) object;

@end