//
//  CCObjcTestModule.h
//  Coherence
//
//  Created by Tony Stone on 1/25/16.
//  Copyright © 2016 Tony Stone. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Coherence;

@interface CCObjcTestModule : NSObject <CCModule>

    + (id <CCModule>) instance;

@end