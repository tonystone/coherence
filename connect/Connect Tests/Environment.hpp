//
//  Environment.h
//  Connect
//
//  Created by Tony Stone on 8/21/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#include <gtest/gtest.h>
#import <Connect/MGConnect.h>

//
//  This file is the global setup for all tests.
//  MGConnect only needs to be initialized once so that
//  is done here
//
namespace mg {
namespace test {

    //
    // Setup the global environment for all tests
    //
    class Environment : public testing::Environment {
    public:
        virtual ~Environment() {}

        virtual void SetUp() {
            
            [MGConnect initializeWithOptions: @{
                                                MGConnectMainThreadManagedObjectContextLimitOption: @1,
                                                MGConnectTakeOverCoreDataOption: @YES}
             ];
        }
        
        virtual void TearDown() {}
    };

}   // namespace test
}   // namespace mg