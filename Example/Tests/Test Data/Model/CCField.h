//
//  CCField.h
//  Coherence
//
//  Created by Tony Stone on 4/30/15.
//  Copyright (c) 2015 Tony Stone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CCField : NSManagedObject

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * name;


@end
