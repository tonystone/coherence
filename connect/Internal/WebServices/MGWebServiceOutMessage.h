//
//  MGWebServiceOutMessage.h
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceMessage.h"

@interface MGWebServiceOutMessage : MGWebServiceMessage

- (id) responseData;
- (void) setResponseData: (id) data;

@end
