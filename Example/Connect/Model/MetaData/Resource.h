//
//  Resource.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Link : NSObject
@property (nonatomic, strong) NSString * rel;
@property (nonatomic, strong) NSString * href;
@end


@interface Resource : NSManagedObject

@property (nonatomic) NSString * name;
@property (nonatomic) NSString * resourceReference;
@property (nonatomic) NSString * textDescription;
@property (nonatomic) id providerProperties;
@property (nonatomic) id providerPrivateData;
@property (nonatomic) Link * resourceReferenceLink;

@end
