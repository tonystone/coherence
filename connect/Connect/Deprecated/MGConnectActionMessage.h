//
//  MGConnectActionMessage.h
//  Connect
//
//  Created by Tony Stone on 5/27/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObject;

/**
 Class Cluster representing an input message for action execution.
 */
@interface MGConnectActionMessage : NSObject

    /**
     Returns an empty MGConnectActionMessage message for calls that do not require data input
     */
    + (MGConnectActionMessage *) actionMessage;

    /**
     Returns an MGConnectActionMessage initialized with an NSManagedObject
     */
    + (MGConnectActionMessage *) actionMessageWithManagedObject: (NSManagedObject *) managedObject;

    /**
     Returns an MGConnectActionMessage initialized with an valuesAndKeys as well 
     as the keys that reference values that were change in valuesAndKeys
     */
    + (MGConnectActionMessage *) actionMessageWithDictionary: (NSDictionary *) valuesAndKeys updatedValueKeys: (NSArray *) updatedValueKeys;

    /**
     Retuns a dictionary with valuesAndKeys that represent the input to 
     a entityAction execution.
     
     NOTE: If you subclass this class you must override this method with 
           your own implementation.
     */
    - (NSDictionary *) valuesAndKeys;

    /**
     Retuns an array with keys for values in the valuesAndKeys 
     that have values that have changed.  Changed is defined as new, in 
     the case of a create operation, updated in the case of an update operation.
     
     NOTE: If you subclass this class you must override this method with
           your own implementation.
     */
    - (NSArray *) updatedValueKeys;

@end
