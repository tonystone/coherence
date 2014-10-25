//
//  MGSimpleQueryAnalyzer.h
//  Connect
//
//  Created by Tony Stone on 5/29/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGFetchRequestAnalyzer.h"

@interface MGRESTfulFetchRequestAnalyzer : MGFetchRequestAnalyzer

@end


@interface MGRESTfulFetchRequestAnalyzer (TestOnly)

- (NSPredicate *) entitySearchPredicateWithPredicate: (NSPredicate *) aPredicate forKey: (NSString *) key;

@end