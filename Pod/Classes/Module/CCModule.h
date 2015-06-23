//
// Created by Tony Stone on 5/7/15.
//

#import <UIKit/UIKit.h>

@protocol CCResourceService;
@protocol CCResource;
@protocol CCConfiguration;

@protocol CCModule <NSObject>

@required

    /**
    *
    */
    + (id <CCModule>) instance;

    /**
    *
    */
    - (void) start;

    /**
    *
    */
    - (void) stop;

    /**
    *
    */
    - (id)serviceForProtocol: (Protocol *)aProtocol;

    /**
    *
    */
    - (UIViewController *) rootViewController;

@end