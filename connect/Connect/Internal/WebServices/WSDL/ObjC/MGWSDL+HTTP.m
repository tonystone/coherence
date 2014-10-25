//
//  MGWSDL+HTTP.m
//  MGConnect
//
//  Created by Tony Stone on 4/11/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDL+HTTP.h"

NSString * const MGWSDLHTTPExtensionPropertyCookies                   = @"cookies";
NSString * const MGWSDLHTTPExtensionPropertyMethod                    = @"method";
NSString * const MGWSDLHTTPExtensionPropertyLocation                  = @"location";
NSString * const MGWSDLHTTPExtensionPropertyIgnoreUncited             = @"ignoreUncited";
NSString * const MGWSDLHTTPExtensionPropertyInputSerialization        = @"inputSerialization";
NSString * const MGWSDLHTTPExtensionPropertyOutputSerialization       = @"outputSerialization";
NSString * const MGWSDLHTTPExtensionPropertyTransferCodingDefault     = @"transferCodingDefault";
NSString * const MGWSDLHTTPExtensionPropertyTransferCoding            = @"transferCoding";
NSString * const MGWSDLHTTPExtensionPropertyQueryParameterSeparator   = @"queryParameterSeparator";
NSString * const MGWSDLHTTPExtensionElementHeader                     = @"header";

NSString * const MGWSDLHTTPExtensionValueQueryParameterSeparatorDefault = @"&";
NSString * const MGWSDLHTTPExtensionValueSerializationURLEncoded        = @"application/x-www-form-urlencoded";
NSString * const MGWSDLHTTPExtensionValueSerializationXML               = @"application/xml";
NSString * const MGWSDLHTTPExtensionValueSerializationJSON              = @"application/json";
NSString * const MGWSDLHTTPExtensionValueSerializationMultiPartFormData = @"multipart/form-data";


MGWSDLHTTPExtensionMethod const MGWSDLHTTPExtensionMethodGET     = @"GET";
MGWSDLHTTPExtensionMethod const MGWSDLHTTPExtensionMethodPOST    = @"POST";
MGWSDLHTTPExtensionMethod const MGWSDLHTTPExtensionMethodPUT     = @"PUT";
MGWSDLHTTPExtensionMethod const MGWSDLHTTPExtensionMethodDELETE  = @"DELETE";