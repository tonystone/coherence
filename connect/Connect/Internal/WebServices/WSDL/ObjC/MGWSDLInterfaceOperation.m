//
//  MGWSDLInterfaceOperation.m
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLInterfaceOperation.h"
#import "MGWSDLInterfaceMessageReference.h"
#import "MGWSDLInterfaceFaultReference.h"

MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternInOnly        = @"In-only";
MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternRobustInOnly  = @"Robust-in-only";
MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternInOut         = @"In-out";
MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternInOptOut      = @"In-opt-out";
MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternOutIn         = @"Out-in";
MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternOutOptIn      = @"Out-opt-in";
MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternOutOnly       = @"Out-only";
MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternRobustOutOnly = @"Robust-out-only";

@class MGWSDLInterface;

@implementation MGWSDLInterfaceOperation {
    MGWSDLMessageExchangePattern messageExchangePattern;
    NSString                   * style;
    
    NSMutableDictionary        * interfaceMessageReferences;
    NSMutableDictionary        * interfaceFaultReferences;
    
    MGWSDLInterface __unsafe_unretained * parent;
}

- (MGWSDLMessageExchangePattern) messageExchangePattern {
    return messageExchangePattern;
}

- (NSString *) style {
    return style;
}

- (MGWSDLInterface *) parent {
    return parent;
}

- (NSString *) description {
    return [self descriptionForLevel: 0];
}

- (NSString *) descriptionForLevel:(NSUInteger)level {
    
    NSMutableString * description = [NSMutableString stringWithFormat: @"<%@ : %p>: pattern: %@ style: %@", NSStringFromClass([self class]), self, messageExchangePattern, style];
    
    [description appendString: [self dictionaryString: interfaceMessageReferences name: @"interfaceMessageReferences" level: level+1]];
    [description appendString: [self dictionaryString: interfaceFaultReferences   name: @"interfaceFaultReferences"   level: level+1]];
    
    return description;
}

@end


@implementation MGWSDLInterfaceOperation (Initialization)

- (id) initWithName: (NSString *) name {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id) initWithName: (NSString *) name messageExchangePattern: (MGWSDLMessageExchangePattern) aMessageExchangePattern {
    
    NSParameterAssert(name != nil);
    NSParameterAssert(aMessageExchangePattern != nil);

    if ((self = [super initWithName: name])) {
        messageExchangePattern = aMessageExchangePattern;
        
        interfaceMessageReferences = [[NSMutableDictionary alloc] init];
        interfaceFaultReferences   = [[NSMutableDictionary alloc] init];
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

- (void) addInterfaceMessageReference: (MGWSDLInterfaceMessageReference *) anInterfaceMessageReference {
    [interfaceMessageReferences setValue: anInterfaceMessageReference forKey: [anInterfaceMessageReference name]];
    [anInterfaceMessageReference setParent: self];
}

- (void)   addInterfaceFaultReference: (MGWSDLInterfaceFaultReference *) anInterfaceFaultReference {
    [interfaceFaultReferences setValue: anInterfaceFaultReference forKey: [anInterfaceFaultReference name]];
    [anInterfaceFaultReference setParent: self];
}

@end
