//
//  MGWSDLMessageReference.m
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLInterfaceMessageReference.h"
#import "MGWSDLInterfaceOperation.h"
#import "MGWSDLElementDeclaration.h"



@implementation MGWSDLInterfaceMessageReference {
    NSString *                 messageLabel;
    MGWSDLMessageDirection     direction;
    MGWSDLMessageContentModel  messageContentModel;
    MGWSDLElementDeclaration * elementDeclaration;
    
    MGWSDLInterfaceOperation __unsafe_unretained * parent;
}

- (NSString *) messageLabel {
    return messageLabel;
}

- (MGWSDLMessageDirection) direction {
    return direction;
}

- (MGWSDLMessageContentModel) messageContentModel {
    return messageContentModel;
}

- (MGWSDLElementDeclaration *) elementDeclaration {
    return elementDeclaration;
}

- (MGWSDLInterfaceOperation *) parent {
    return parent;
}

- (NSString *) description {
    return [self descriptionForLevel: 0];
}

- (NSString *) descriptionForLevel:(NSUInteger)level {
    
    NSMutableString * description = [NSMutableString stringWithFormat: @"<%@ : %p>: messageLabel: %@ direction: %@ messageContentModel: %@ elementDeclaration: %@", NSStringFromClass([self class]), self, messageLabel, direction, messageContentModel, elementDeclaration ? [elementDeclaration name] : @"none"];
    
    return description;
}

@end


@implementation MGWSDLInterfaceMessageReference (Initialization)

- (id) initWithName:(NSString *)name {
    [self doesNotRecognizeSelector: _cmd];
    
    return nil;
}

- (id) initWithName: (NSString *) name messageLabel: (NSString *) aMessageLabel direction: (MGWSDLMessageDirection) aDirection messageContentModel: (MGWSDLMessageContentModel) aMessageContentModel {
    
    NSParameterAssert(name != nil);
    NSParameterAssert(aMessageLabel != nil);
    NSParameterAssert(aDirection != nil);
    NSParameterAssert(aMessageContentModel != nil);
    
    if ((self = [super initWithName: name])) {
        messageLabel        = aMessageLabel;
        direction           = aDirection;
        messageContentModel = aMessageContentModel;
    }
    
    return self;
}

- (void) setParent: (MGWSDLInterfaceOperation *) aParent {
    
    //
    // Note: parent is required so you can't set it to nil
    //
    NSParameterAssert(aParent != nil);
    
    if (parent != aParent) {
        parent = aParent;
    }
}

- (void) setElementDeclaration: (MGWSDLElementDeclaration *) anElementDeclaration {
    if (elementDeclaration != anElementDeclaration) {
        elementDeclaration = anElementDeclaration;
    }
}

@end