//
//  MGWSDL+Types.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/17/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Message Direction Constent
 */
typedef NSString * MGWSDLMessageDirection;

extern MGWSDLMessageDirection MGWSDLMessageDirectionIn;
extern MGWSDLMessageDirection MGWSDLMessageDirectionOut;

/**
 Message Content Type Constent
 */
typedef NSString * MGWSDLMessageContentModel;

extern MGWSDLMessageContentModel MGWSDLMessageContentModelAny;
extern MGWSDLMessageContentModel MGWSDLMessageContentModelNone;
extern MGWSDLMessageContentModel MGWSDLMessageContentModelOther;
extern MGWSDLMessageContentModel MGWSDLMessageContentModelElement;

