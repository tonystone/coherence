//
//  ConnectCommon.h
//  Connect-Common
//
//  Created by Tony Stone on 10/27/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for Connect.
FOUNDATION_EXPORT double ConnectCommonVersionNumber;

//! Project version string for Connect.
FOUNDATION_EXPORT const unsigned char ConnectCommonVersionString[];

#import <ConnectCommon/MGAssert.h>
#import <ConnectCommon/MGTraceLog.h>
#import <ConnectCommon/MGConfigurationReader.h>

// Connect WADL Model
#import <ConnectCommon/MGConnectWADLAction.h>
#import <ConnectCommon/MGConnectWADLAuthentication.h>
#import <ConnectCommon/MGConnectWADLCollection.h>
#import <ConnectCommon/MGConnectWADLElement.h>
#import <ConnectCommon/MGConnectWADLEntity.h>
#import <ConnectCommon/MGConnectWADLModel.h>
#import <ConnectCommon/MGConnectWADLRelationship.h>

// WADL Model
#import <ConnectCommon/MGWADLApplication.h>
#import <ConnectCommon/MGWADLDoc.h>
#import <ConnectCommon/MGWADLGrammars.h>
#import <ConnectCommon/MGWADLInclude.h>
#import <ConnectCommon/MGWADLLink.h>
#import <ConnectCommon/MGWADLMethod.h>
#import <ConnectCommon/MGWADLOption.h>
#import <ConnectCommon/MGWADLParam.h>
#import <ConnectCommon/MGWADLRepresentation.h>
#import <ConnectCommon/MGWADLRequest.h>
#import <ConnectCommon/MGWADLResource+Extensions.h>
#import <ConnectCommon/MGWADLResources+Extensions.h>
#import <ConnectCommon/MGWADLResourceType.h>
#import <ConnectCommon/MGWADLResponse.h>

// XML Model
#import <ConnectCommon/MGXMLReader.h>
#import <ConnectCommon/MGXMLCDATA.h>
#import <ConnectCommon/MGXMLComment.h>
#import <ConnectCommon/MGXMLDocument.h>
#import <ConnectCommon/MGXMLElement.h>
#import <ConnectCommon/MGXMLElementDefinition.h>
#import <ConnectCommon/MGXMLNode.h>
#import <ConnectCommon/MGXMLWhitespace.h>
