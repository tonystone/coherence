//
//  MGResource.h
//  MGConnect
//
//  Created by Tony Stone on 3/27/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol MGResource <NSObject>

@required
    /**
        ResourceReferece
     */
    @property (nonatomic, readonly) NSString * __rr;
    /**
        created at
     */
    @property (nonatomic, readonly) NSDate   * __ca;
    /**
        updated at
     */
    @property (nonatomic, readonly) NSString * __ua;
@end

@interface MGResource : NSManagedObject

@property (nonatomic, readonly) NSString * __rr;
@property (nonatomic, readonly) NSDate   * __ca;
@property (nonatomic, readonly) NSString * __ua;

@end
