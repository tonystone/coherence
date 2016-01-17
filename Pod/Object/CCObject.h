//
//  CCObject.h
//  Pods
//
//  Created by Tony Stone on 12/18/15.
//
//

#import <Foundation/Foundation.h>

@interface CCObject : NSObject

    + (id) instanceForProtocol: (Protocol *) aProtocol defaults: (NSDictionary *) defaults bundleKey: (NSString *) bundleKey ;

@end
