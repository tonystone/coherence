//
//  MGMetadataManager.h
//  Connect
//
//  Created by Tony Stone on 5/2/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGTransactionLogRecord.h"

@class MGLogWriter;
@class MGLogReader;

@interface MGMetadataManager : NSObject

+ (MGMetadataManager *) sharedManager;

- (MGLogWriter *) logWriter;
- (MGLogReader *) logReader;

- (NSUInteger) nextSequenceNumberBlock: (NSUInteger) size;

@end
