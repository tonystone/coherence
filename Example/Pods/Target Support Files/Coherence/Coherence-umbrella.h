#import <UIKit/UIKit.h>

#import "Coherence.h"
#import "CCCache.h"
#import "CCPersistentStoreCoordinator.h"
#import "CCAssert.h"
#import "CCManagedObjectContext.h"
#import "CCTypeTransformation.h"
#import "CCMetaLogEntry.h"
#import "CCMetaModel.h"
#import "CCWriteAheadLog.h"
#import "NSManagedObjectModel+UniqueIdentity.h"
#import "CCConfiguration.h"
#import "CCModule.h"
#import "CCResource.h"
#import "CCResourceService.h"
#import "NSString+CapitalizeFirstLetter.h"

FOUNDATION_EXPORT double CoherenceVersionNumber;
FOUNDATION_EXPORT const unsigned char CoherenceVersionString[];

