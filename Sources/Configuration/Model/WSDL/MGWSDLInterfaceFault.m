//
//  MGWSDLInterfaceFault.m
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLInterfaceFault.h"
#import "MGWSDLInterface.h"
#import "MGWSDLElementDeclaration.h"

@implementation MGWSDLInterfaceFault {
    MGWSDLMessageContentModel  messageContentModel;
    MGWSDLElementDeclaration * elementDeclaration;
    
    MGWSDLInterface __unsafe_unretained * parent;
}

- (MGWSDLMessageContentModel) messageContentModel {
    return messageContentModel;
}

- (MGWSDLElementDeclaration *) elementDeclaration {
    return elementDeclaration;
}

- (MGWSDLInterface *) parent {
    return parent;
}

- (NSString *) description {
    return [self descriptionForLevel: 0];
}

- (NSString *) descriptionForLevel:(NSUInteger)level {
    
    NSMutableString * description = [NSMutableString stringWithFormat: @"<%@ : %p>:  messageContentModel: %@ elementDeclaration: %@", NSStringFromClass([self class]), self, messageContentModel, elementDeclaration ? [elementDeclaration name] : @"none"];
    
    return description;
}

@end

@implementation MGWSDLInterfaceFault (Initialization)

- (id) initWithName:(NSString *)name {
    [self doesNotRecognizeSelector: _cmd];
    
    return nil;
}

- (id) initWithName: (NSString *) name messageContentModel: (MGWSDLMessageContentModel) aMessageContentModel {
    
    NSParameterAssert(name != nil);
    NSParameterAssert(aMessageContentModel != nil);
    
    if ((self = [super initWithName: name])) {
        
        messageContentModel = aMessageContentModel;
    }
    return self;
}

- (void) setParent: (MGWSDLInterface __unsafe_unretained *) aParent {
    
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
