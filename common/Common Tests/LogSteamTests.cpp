//
// Created by Tony Stone on 8/16/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#include <gtest/gtest.h>
#include "LogStream.h"

using mg::LogStream;

namespace mg {
namespace test {

    typedef struct {
        const char * message;
    } TestDataObject;

    static TestDataObject testData[] = {
            {"This is the first test message"},
            {"This is the second test message"},
            {""},
            {" "},
            {"~!@#$%^&*()_+`-={}[]|:;'<>,.?/'"},
    };

    class LogStreamTest : public testing::TestWithParam<mg::test::TestDataObject>  {

        protected:

            virtual void SetUp () {

            };

            virtual void TearDown () {

            };
    };

}   // namespace test
}   // namespace mg

using namespace mg::test;

INSTANTIATE_TEST_CASE_P(Tests, LogStreamTest, testing::ValuesIn(mg::test::testData));

TEST_P(LogStreamTest, testPrint)
{
    TestDataObject testData = GetParam();
}
