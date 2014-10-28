//
//  MGConnect.h
//  MGConnect
//
//  Created by Tony Stone on 7/2/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for Connect.
FOUNDATION_EXPORT double ConnectVersionNumber;

//! Project version string for Connect.
FOUNDATION_EXPORT const unsigned char ConnectVersionString[];

#import <Connect/MGPersistentStoreCoordinator.h>
#import <Connect/MGManagedObjectContext.h>

// Exceptions and errors
#import <Connect/MGError.h>
#import <Connect/MGException.h>
#import <Connect/MGInitializationException.h>
#import <Connect/MGRuntimeException.h>
