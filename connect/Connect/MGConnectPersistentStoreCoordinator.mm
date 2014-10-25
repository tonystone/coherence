//
//  MGConnectPersistentStoreCoordinator.m
//  Connect
//
//  Created by Tony Stone on 5/12/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectPersistentStoreCoordinator.h"
#import <Common/LogStream.h>
#import "MGConnectModelMangler.h"

using mg::LogStream;

//
// Main implementation
//
@implementation MGConnectPersistentStoreCoordinator {

}

#pragma mark NSPersistentStoreCoordinator override methods

- (id) initWithManagedObjectModel: (NSManagedObjectModel *) aModel connectConfiguration: (NSString *) configurationFileName {
    
    NSParameterAssert(aModel != nil);

    LogStream::cout << LogStream::LogLevel::TRACE << "Initializing " << [NSStringFromClass([self class]) cStringUsingEncoding: NSUTF8StringEncoding]  << " instance." << std::endl;

    //
    // Process the model before giving it to the super class
    //
    [MGConnectModelMangler configureModel: aModel forConnectConfiguration: nil];

    if ((self = [super initWithManagedObjectModel: aModel])) {

        // Look for a Connect Model file to create a connect managed model for the persistent stores


    }
    return self;
}

- (NSPersistentStore *) addPersistentStoreWithType:(NSString *)storeType configuration:(NSString *)configuration URL:(NSURL *)storeURL options:(NSDictionary *)options error:(NSError *__autoreleasing *)error {

    LogStream::cout << LogStream::LogLevel::TRACE << "Attaching persistent store: " << [[storeURL path] cStringUsingEncoding: NSUTF8StringEncoding] << std::endl;

    NSPersistentStore * newStore =  [super addPersistentStoreWithType: storeType configuration: configuration URL: storeURL options: options error: error];

    //
    //  If this is a Connect store, we need to setup the remaining structure.
    //


    return newStore;
}

- (BOOL) removePersistentStore:(NSPersistentStore *)store error:(NSError *__autoreleasing *)error {

    LogStream::cout << LogStream::LogLevel::TRACE << "Removing persistent store: " << [[[store URL] path] cStringUsingEncoding: NSUTF8StringEncoding] << std::endl;

    return [super removePersistentStore: store error: error];
}

@end
