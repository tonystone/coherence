//
//  MGConnectActionExecutionInfo.m
//  Connect
//
//  Created by Tony Stone on 5/25/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectActionExecutionInfo.h"

//
// Internal static data
//
static NSArray * actionCompletionStatusStrings;
static NSArray * actionStateStrings;

//
// Initialize internal static structures
//
__attribute__((constructor)) static void initialize_internal_statics() {
    
    actionStateStrings            = @[@"Pending",    @"Excuting", @"Finished"];
    actionCompletionStatusStrings = @[@"Successful", @"Cancelled",@"Failed"];
}

@implementation MGConnectActionExecutionInfo

- (NSDate *) startTime {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSDate *) endTime {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSTimeInterval) executionTime {
    [self doesNotRecognizeSelector: _cmd];
    return 0;
}

- (MGConnectActionCompletionStatus) completionStatus {
    [self doesNotRecognizeSelector: _cmd];
    return MGConnectActionCompletionStatusFailed;
}

- (NSError *) error {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSDictionary *) userInfo {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSString *) description {
    return [NSString stringWithFormat: @"<%@ : %p> {\r\tcompletion status: %@\r\tstart time: %@\r\tend time: %@\r\texecution time: %0.5f%@\r}\r",
            NSStringFromClass([self class]),
            self,
            [self stringFromActionCompletionStatus: [self completionStatus]],
            [self startTime],
            [self endTime],
            [self executionTime],
            [self error] ? [NSString stringWithFormat: @"\r\terror: %@", [self error]] : @""];
}

            
- (NSString *) stringFromActionCompletionStatus: (MGConnectActionCompletionStatus) aStatus {
    
    if (aStatus < [actionCompletionStatusStrings count]) {
        return [actionCompletionStatusStrings objectAtIndex: aStatus];
    }
    return @"Unknown";
}

@end
