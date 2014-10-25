//
// Created by Tony Stone on 8/15/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#include <gtest/gtest.h>
#import "Connect/MGConnect.h"


TEST(MGConnect, testVersionInfo) {

    MGVersion version = [MGConnect versionInfo];

    //
    // Simple tests to make sure that the
    // versionInfo of MGConnect returns
    // the same static version it defines.
    //
    ASSERT_TRUE(version.major == MGConnectVersion_MAJOR);
    ASSERT_TRUE(version.minor == MGConnectVersion_MINOR);
    ASSERT_TRUE(version.build == MGConnectVersion_BUILD);
}

TEST(MGConnect, testDoubleInitialization) {

    //
    // This should throw an exception
    // since we are already initialized
    // in the Environment SetUp method.
    //
    EXPECT_ANY_THROW ({
          [MGConnect initializeWithOptions: @{}];
    });
}




