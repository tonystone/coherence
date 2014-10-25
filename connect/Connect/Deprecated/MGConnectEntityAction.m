//
//  MGConnectEntityAction.m
//  Connect
//
//  Created by Tony Stone on 5/23/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectEntityAction.h"

#import "MGTraceLog.h"
#import "MGConnectAction.h"

NSString * const MGEntityActionTypeList     = @"list";
NSString * const MGEntityActionTypeRead     = @"read";
NSString * const MGEntityActionTypeCreate   = @"insert";
NSString * const MGEntityActionTypeUpdate   = @"update";
NSString * const MGEntityActionTypeDelete   = @"delete";

/**
 */
@implementation MGConnectEntityAction {
    NSEntityDescription * entity;
}

@dynamic name;
@dynamic entity;

- (id) initWithName: (NSString *) aName entity: (NSEntityDescription *) anEntity {
    
    if ((self = [super initWithName: aName])) {
        entity = anEntity;
    }
    return self;
}

- (NSString *) name {
    return [super name];
}

- (NSEntityDescription *) entity {
    return entity;
}

- (MGConnectActionCompletionStatus) execute:(id)userData inMessage: (MGConnectActionMessage *) inMessage error:(NSError *__autoreleasing *)error {
    [self doesNotRecognizeSelector: _cmd];
    
    return MGConnectActionCompletionStatusFailed;
}

- (NSString *) description {
    return [NSString stringWithFormat: @"<%@: %p> \r{\r\tname: %@\r\tdependencies: %u\r\tentity: <%@: %p>\r\t{\r\t\tname: %@\r\t}\r}\r", NSStringFromClass([self class]), self, [self name], [[self dependencies] count], NSStringFromClass([[self entity] class]), [self entity], [[self entity] name]];
}

@end

