//
//  MGConnectEntityAction.h
//  Connect
//
//  Created by Tony Stone on 5/22/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGConnectAction.h"


/**
 Entity Actions
 */
extern NSString * const MGEntityActionTypeList;
extern NSString * const MGEntityActionTypeRead;
extern NSString * const MGEntityActionTypeCreate;
extern NSString * const MGEntityActionTypeUpdate;
extern NSString * const MGEntityActionTypeDelete;

//
// Forward Definitions
//
@class NSEntityDesciption;

/**
 The MGConnectEntityAction protocol specifies the required
 methods and properties to support entity data access isolation.
 */
@protocol MGConnectEntityAction <MGConnectAction>

@required
    @property (nonatomic, readonly) NSEntityDescription * entity;

@end

/**
 It is optional to subclass MGConnectEntityAction but if you do
 you get the added benifit of having dependencies and storage for 
 the NSEntityDescription
 */
@interface MGConnectEntityAction  : MGConnectAction <MGConnectEntityAction>

    /**
     
     The {locations} parameter MAY cite local names of elements from the instance data of the message to be
     serialized in request IRI by enclosing the element name within curly braces (e.g. "temperature/{town}"):
     
     When constructing the request IRI, each pair of curly braces (and enclosed element name) is replaced by the possibly 
     empty single value of the corresponding element. If a local name appears more than once, the elements are used in the 
     order they appear in the instance data. It is an error for this element to carry an xs:nil attribute whose value is "true".
     
     A double curly brace (i.e. "{{" or "}}") MAY be used to include a single, literal curly brace in the request IRI.
     
     Strings enclosed within single curly braces MUST be element names from the instance data of the input message; local names within 
     single curly braces not corresponding to an element in the instance data are a fatal error.†
     
     Example 1:
     
     Model
     
        Company
            NSString * id;
            NSSet    * employees;
     
         Emplyee
            NSString * id;
            Company  * company;
            Person   * person;
         
         Person
            NSString * id;
            NSSet    * parents;
            NSSet    * children;
     
     CompanyWebServiceDefinition.actionLocations
     
        list = /company
        read = /company/{self.id}
     
     EmployeeWebServiceDefinition.actionLocations
     
        list = /company/{company.id}/employees
        read = /company/{company.id}/employees/{self.id}

     Example 2 (RightScale example):
     
     RESTful urls
     
        /clouds/{cloudID}/instances/{instanceID}
     
     Paramatized URLs
     
        /instances?id={instanceID}&cloud_id={cloudID}
     
     */
/*
    + (MGConnectEntityAction *)   listEntityAction: (MGConnectWebServiceHTTPDefinition *) webServiceDefinition method: (NSString *) aMethod location: (NSString *) aLocationTemplate inMessage: (id) inMessage mapper: (id) aMapper;
    + (MGConnectEntityAction *)   readEntityAction: (MGConnectWebServiceHTTPDefinition *) webServiceDefinition method: (NSString *) aMethod location: (NSString *) aLocationTemplate inMessage: (id) inMessage mapper: (id) aMapper;
    + (MGConnectEntityAction *) createEntityAction: (MGConnectWebServiceHTTPDefinition *) webServiceDefinition method: (NSString *) aMethod location: (NSString *) aLocationTemplate inMessage: (id) inMessage;
    + (MGConnectEntityAction *) updateEntityAction: (MGConnectWebServiceHTTPDefinition *) webServiceDefinition method: (NSString *) aMethod location: (NSString *) aLocationTemplate inMessage: (id) inMessage;
    + (MGConnectEntityAction *) deleteEntityAction: (MGConnectWebServiceHTTPDefinition *) webServiceDefinition method: (NSString *) aMethod location: (NSString *) aLocationTemplate inMessage: (id) inMessage;
*/
    /**
     Designated initializer
     
     Note:  if you subclass this class you must chain to this
            initializer in your init method.
     */
    - (id) initWithName: (NSString *) name entity: (NSEntityDescription *) entity;

    /**
     Returns the entity this MGConnectEntityAction was initialized with.
     */
    - (NSEntityDescription *) entity;

@end
