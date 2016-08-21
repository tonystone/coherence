//
//  MGWebServiceInMessage.h
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceMessage.h"

@interface MGWebServiceInMessage : MGWebServiceMessage

- (NSDictionary *) headers;
- (NSDictionary *) parameters;

- (NSDictionary *) instanceData;
- (void) setInstanceData: (NSDictionary *) data;

- (void) addValue: (NSString *) aValue forHeaderField: (NSString *) aHeader;
- (void) setValue: (NSString *) aValue forHeaderField: (NSString *) aHeader;
- (void) addHeaders: (NSDictionary *) headers;

- (void) setValue: (NSString *) aValue forParameter: (NSString *) aParameter;

@end
