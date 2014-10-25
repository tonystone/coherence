//
//  MGConnect+PrivateSettings.h
//  MGConnect
//
//  Created by Tony Stone on 4/15/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect.h"
#import <CoreData/CoreData.h>

@class MGWebService;
@class MGDataMergeOperation;
@protocol MGObjectMapper;

@protocol MGPrivateEntitySettings <NSObject>

@required

    /**
     Is this entity managed by MGConnect
     */
    @property (nonatomic, assign) BOOL managed;

    /**
     The webService Associated with this entity
     */
    @property (nonatomic, strong) NSMutableDictionary * actions;

    /**
     Object to map between source and target and vs versa
     */
    @property (nonatomic, strong) NSObject <MGObjectMapper> * objectMapper;


    @property (nonatomic, strong) MGDataMergeOperation * dataMergeOperation;

    @property (nonatomic, strong) MGWebService * webService;

@end

@interface NSEntityDescription (MGPrivateSettings) <MGPrivateEntitySettings>
// Note:  All protocol MGEntitySettings properties are implemented
@end

@protocol MGPrivateModelSettings <NSObject>

@required
    /**
     The query analyzer to use for this model
     */
    @property (nonatomic, strong) id  queryAnalyzer;


@end

@interface NSManagedObjectModel (MGPrivateSettings) <MGPrivateModelSettings>
// Note:  All protocol MGEntitySettings properties are implemented
@end

