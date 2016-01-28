//
//  CCObjcTestModule.m
//  Coherence
//
//  Created by Tony Stone on 1/25/16.
//  Copyright © 2016 Tony Stone. All rights reserved.
//

#import "CCObjcTestModule.h"
@import Coherence;

@implementation CCObjcTestModule

    + (id <CCModule>) instance {
        return [[self alloc] init];
    }

    - (void) start {}
    - (void) stop {}

    - (id <CCResourceService>) serviceForProtocol: (Protocol *) aProtocol {
        return nil;
    }

    - (UIViewController *) rootViewController {
        return nil;
    }
@end
