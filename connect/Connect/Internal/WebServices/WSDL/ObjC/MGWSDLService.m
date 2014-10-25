//
//  MGWSDLService.m
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLService.h"
#import "MGWSDLInterface.h"
#import "MGWSDLEndpoint.h"

@implementation MGWSDLService {
    MGWSDLInterface * interface;
    NSMutableDictionary * endpoints;
}

- (MGWSDLInterface *) interface {
    return interface;
}

- (NSDictionary *) endpoints {
    return endpoints;
}

- (NSString *) description {
    return [self descriptionForLevel: 0];
}

- (NSString *) descriptionForLevel:(NSUInteger)level {
    
    NSMutableString * description = [NSMutableString stringWithFormat: @"<%@ : %p>: interface: %@", NSStringFromClass([self class]), self, [interface name]];
    
    [description appendString: [self dictionaryString: endpoints name: @"endpoints" level: level+1]];
    
    return description;
}

@end


@implementation MGWSDLService (Initialization)

- (id) initWithName:(NSString *)name {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id) initWithName:(NSString *)name interface: (MGWSDLInterface *) anInterface endpoint: (MGWSDLEndpoint *) anEndpoint {
    
    NSParameterAssert(name != nil);
    NSParameterAssert(anInterface != nil);
    NSParameterAssert(anEndpoint != nil);
    
    if ((self = [super initWithName: name])) {
        interface = anInterface;
        endpoints = [[NSMutableDictionary alloc] initWithCapacity: 1];
        
        [endpoints setObject: anEndpoint forKey: [anEndpoint name]];
        [anEndpoint setParent: self];
    }
    return self;
}

- (void) addEndpoint: (MGWSDLEndpoint *) anEndpoint {
    
    NSParameterAssert(anEndpoint != nil);
    
    [endpoints setValue: anEndpoint forKey: [anEndpoint name]];
    [anEndpoint setParent: self];
}

@end
