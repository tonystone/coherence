//
// Created by Tony Stone on 4/30/15.
//

#import <Foundation/Foundation.h>

@class CCBackingStore;


@interface CCSynchronizationManager : NSObject

    - (instancetype) initWithCache: (CCBackingStore *) aCache metaCache: (CCBackingStore *) aMetaCache;

    - (void) start;
    - (void) stop;

@end