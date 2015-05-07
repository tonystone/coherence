//
// Created by Tony Stone on 4/30/15.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol CCAction;

@interface Coherence : NSObject

    - (instancetype)initWithIdentifier: (NSString *) anIdentifier managedObjectModel:(NSManagedObjectModel *)model;

    - (void) start;
    - (void) stop;

    - (NSManagedObjectContext *) mainThreadContext;
    - (NSManagedObjectContext *) editContext;

@end
