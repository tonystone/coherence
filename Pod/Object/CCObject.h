//
//  CCObject.h
//  Pods
//
//  Created by Tony Stone on 12/18/15.
//
//

#import <Foundation/Foundation.h>

@interface CCObject : NSObject

    + (Class) classForProtocol: (Protocol *) aProtocol baseClass: (Class) baseClass;

@end
