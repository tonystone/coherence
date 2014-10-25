//
//  MGConnectTestCommon.m
//  MGConnect
//
//  Created by Tony Stone on 4/15/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectTestCommon.h"
#import "MGConnect+DataStoreConfiguration.h"
#import <CoreData/CoreData.h>


@implementation MGConnectTestCommon


+ (void)initialize {
    
    if (self == [MGConnectTestCommon class]) {
        //
        // Initialize the GMResourceManager
        //
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSURL * metaDataModelURL = [bundle URLForResource: @"MetaData" withExtension: @"mom"];
        NSManagedObjectModel * metaDataModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: metaDataModelURL];
        
        NSURL * dataCacheModelURL = [bundle URLForResource: @"DataCache" withExtension: @"mom"];
        NSManagedObjectModel * dataCacheModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: dataCacheModelURL];
        
        [[MGConnect sharedManager] registerDataStore: kConfigDataStore managedObjectModel: metaDataModel];
        [[MGConnect sharedManager] registerDataStore: kCloudDataStore managedObjectModel: dataCacheModel];
        //
        // End MGConnect initialization
        //
    }
}

- (void) login {
    
    NSMutableString * parameterString = [[NSMutableString alloc] initWithFormat: @"email=%@&password=%@&account_href=/api/accounts/%@",
                                         @"hatter24@gmail.com", @"cl0udw@tch", @"43770"];
	// Create the url.
    NSString * path = @"https://my.rightscale.com/api/session";
	NSURL    * url  = [NSURL URLWithString: path];
    
	// Create the request.
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url
                                                           cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval: 60 ];
    [request setHTTPMethod: @"POST"];
    [request setValue: @"1.5"  forHTTPHeaderField: @"X_API_VERSION"];
	[request setHTTPShouldHandleCookies: YES];
    [request setHTTPBody: [parameterString  dataUsingEncoding: NSASCIIStringEncoding]];
    
    NSHTTPURLResponse * response = nil;
    NSError           * error    = nil;
    
    // Make the synchronous request
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
    
    if ([response statusCode] == 204) {
        
    } else {
        // FIXME: we need real error hanlding here to give the user the proper feedback
    }
}

@end
