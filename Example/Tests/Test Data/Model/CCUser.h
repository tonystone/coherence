//
//  CCUser.h
//  Coherence
//
//  Created by Tony Stone on 4/30/15.
//  Copyright (c) 2015 Tony Stone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CCUser : NSManagedObject

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;

    - (BOOL)isEqual:(id)other;

    - (BOOL)isEqualToUser:(CCUser *)user;

    - (NSUInteger)hash;

@end
