//
//  main.cpp
//  Connect
//
//  Created by Tony Stone on 8/21/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#include <gtest/gtest.h>
#include "Environment.hpp"


int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);

    AddGlobalTestEnvironment(new mg::test::Environment);

    return RUN_ALL_TESTS();
}
