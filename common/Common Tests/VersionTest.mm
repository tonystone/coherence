//
// Created by Tony Stone on 2/12/14.
//

#include <gtest/gtest.h>
#include "Common/Version.h"

@interface TestClass : NSObject <MGVersionInfo>
@end
@implementation TestClass

+ (MGVersion) versionInfo {
    return MGMakeVersion(1, 1, 1);
}

@end

TEST(MGVersionTest, testObjectiveCProtocol)
{
    MGVersion version = [TestClass versionInfo];
    
    ASSERT_TRUE(version.major == 1);
    ASSERT_TRUE(version.minor == 1);
    ASSERT_TRUE(version.build == 1);
}

using mg::Version;

namespace mg {
namespace test {

    static Version  versionTests[] = {
            {0,0,0},
            {1,0,1},
            {1,1,1},
            {1,2,1},
            {2,1,2},
            {std::numeric_limits<unsigned int>::max(),std::numeric_limits<unsigned int>::max(),std::numeric_limits<unsigned int>::max()}
    };

    class VersionTest : public testing::Test, public testing::WithParamInterface<Version>  {

    };

}   // namespace test
}   // namespace mg

using namespace mg::test;

INSTANTIATE_TEST_CASE_P(VersionTest, VersionTest, testing::ValuesIn(versionTests));

TEST_P(VersionTest, testConstructionStatic)
{
    ASSERT_NO_THROW(GetParam());
}

TEST_P(VersionTest, testConstructionPtr)
{
    Version testVersion = GetParam();
    Version * resultVersion = NULL;

    ASSERT_NO_THROW((resultVersion = new Version(testVersion.major, testVersion.minor, testVersion.build)));
    ASSERT_TRUE(resultVersion != NULL);
    ASSERT_NO_THROW(delete resultVersion);
}

TEST_P(VersionTest, testEqual)
{
    Version left  = GetParam();
    Version right = left;

    // C++
    ASSERT_TRUE(left == right);
    
    // Objective-C
    ASSERT_TRUE(MGVersionEqual(left,right));
}


TEST_P(VersionTest, testNotEqualMajor)
{
    Version left  = GetParam();
    Version right = left;

    right.major++;

    ASSERT_TRUE(left != right);
}

TEST_P(VersionTest, testNotEqualMinor)
{
    Version left  = GetParam();
    Version right = left;

    right.minor++;

    ASSERT_TRUE(left != right);
}

TEST_P(VersionTest, testNotEqualBuild)
{
    Version left  = GetParam();
    Version right = left;

    right.build++;

    ASSERT_TRUE(left != right);
}

TEST_P(VersionTest, testGreaterThanMajor)
{
    Version left  = GetParam();
    Version right = left;

    //
    // Edge cases are trickier cause
    // if zero or max, you can't
    // increment or decrement
    //
    if (right.major == 0) {
        left.major++;
    } else {
        right.major--;
    }

    ASSERT_TRUE (left  > right);
    ASSERT_FALSE(right > left);
}

TEST_P(VersionTest, testGreaterThanMinor)
{
    Version left  = GetParam();
    Version right = left;

    //
    // Edge cases are trickier cause
    // if zero or max, you can't
    // increment or decrement
    //
    if (right.minor == 0) {
        left.minor++;
    } else {
        right.minor--;
    }

    ASSERT_TRUE (left  > right);
    ASSERT_FALSE(right > left);
}

TEST_P(VersionTest, testGreaterThanBuild)
{
    Version left  = GetParam();
    Version right = left;

    //
    // Edge cases are trickier cause
    // if zero or max, you can't
    // increment or decrement
    //
    if (right.build == 0) {
        left.build++;
    } else {
        right.build--;
    }

    ASSERT_TRUE (left  > right);
    ASSERT_FALSE(right > left);
}

TEST_P(VersionTest, testGreaterThanOrEqualMajor)
{
    Version left  = GetParam();
    Version right = left;

    // Is it equal
    ASSERT_TRUE(left  >= right);
    ASSERT_TRUE(right >= left);

    //
    // Edge cases are trickier cause
    // if zero or max, you can't
    // increment or decrement
    //
    if (right.major == std::numeric_limits<unsigned int>::max()) {
        right.major--;
    } else {
        left.major++;
    }

    // Is it greater than
    ASSERT_TRUE (left  >= right);
    ASSERT_FALSE(right >= left);
}

TEST_P(VersionTest, testGreaterThanOrEqualMinor)
{
    Version left  = GetParam();
    Version right = left;

    // Is it equal
    ASSERT_TRUE(left  >= right);
    ASSERT_TRUE(right >= left);

    //
    // Edge cases are trickier cause
    // if zero or max, you can't
    // increment or decrement
    //
    if (right.minor == std::numeric_limits<unsigned int>::max()) {
        right.minor--;
    } else {
        left.minor++;
    }

    // Is it greater than
    ASSERT_TRUE (left  >= right);
    ASSERT_FALSE(right >= left);
}

TEST_P(VersionTest, testGreaterThanOrEqualBuild)
{
    Version left  = GetParam();
    Version right = left;

    // Is it equal
    ASSERT_TRUE(left  >= right);
    ASSERT_TRUE(right >= left);

    //
    // Edge cases are trickier cause
    // if zero or max, you can't
    // increment or decrement
    //
    if (right.build == std::numeric_limits<unsigned int>::max()) {
        right.build--;
    } else {
        left.build++;
    }

    // Is it greater than
    ASSERT_TRUE (left  >= right);
    ASSERT_FALSE(right >= left);
}

// -------------

TEST_P(VersionTest, testLessThanMajor)
{
    Version left  = GetParam();
    Version right = left;

    //
    // Edge cases are trickier cause
    // if zero or max, you can't
    // increment or decrement
    //
    if (right.major == 0) {
        right.major++;
    } else {
        left.major--;
    }

    ASSERT_TRUE (left  < right);
    ASSERT_FALSE(right < left);
}

TEST_P(VersionTest, testLessThanMinor)
{
    Version left  = GetParam();
    Version right = left;

    //
    // Edge cases are trickier cause
    // if zero or max, you can't
    // increment or decrement
    //
    if (right.minor == 0) {
        right.minor++;
    } else {
        left.minor--;
    }

    ASSERT_TRUE (left  < right);
    ASSERT_FALSE(right < left);
}

TEST_P(VersionTest, testLessThanBuild)
{
    Version left  = GetParam();
    Version right = left;

    //
    // Edge cases are trickier cause
    // if zero or max, you can't
    // increment or decrement
    //
    if (right.build == 0) {
        right.build++;
    } else {
        left.build--;
    }

    ASSERT_TRUE (left  < right);
    ASSERT_FALSE(right < left);
}

TEST_P(VersionTest, testLessThanOrEqualMajor)
{
    Version left  = GetParam();
    Version right = left;

    // Is it equal
    ASSERT_TRUE(left  <= right);
    ASSERT_TRUE(right <= left);

    //
    // Edge cases are trickier cause
    // if zero or max, you can't
    // increment or decrement
    //
    if (right.major == 0) {
        right.major++;
    } else {
        left.major--;
    }

    ASSERT_TRUE (left  <= right);
    ASSERT_FALSE(right <= left);

}

TEST_P(VersionTest, testLessThanOrEqualMinor)
{
    Version left  = GetParam();
    Version right = left;

    // Is it equal
    ASSERT_TRUE(left  <= right);
    ASSERT_TRUE(right <= left);

    //
    // Edge cases are trickier cause
    // if zero or max, you can't
    // increment or decrement
    //
    if (right.minor == 0) {
        right.minor++;
    } else {
        left.minor--;
    }

    ASSERT_TRUE (left  <= right);
    ASSERT_FALSE(right <= left);

}

TEST_P(VersionTest, testLessThanOrEqualBuild)
{
    Version left  = GetParam();
    Version right = left;

    // Is it equal
    ASSERT_TRUE(left  <= right);
    ASSERT_TRUE(right <= left);

    //
    // Edge cases are trickier cause
    // if zero or max, you can't
    // increment or decrement
    //
    if (right.build == 0) {
        right.build++;
    } else {
        left.build--;
    }

    ASSERT_TRUE (left  <= right);
    ASSERT_FALSE(right <= left);

}

namespace mg {
    namespace test {

        typedef struct {
            Version version;
            char const * versionStr;
        } VersionTestData;

        static VersionTestData  versionStrTests[] = {
                {{0,0,0}, "0.00 (0)"},
                {{1,0,1}, "1.00 (1)"},
                {{1,1,1}, "1.01 (1)"},
                {{1,2,1}, "1.02 (1)"},
                {{2,1,2}, "2.01 (2)"},
                {{20,100,2000}, "20.100 (2000)"},
        };

        class VersionStrTest : public testing::Test, public testing::WithParamInterface<mg::test::VersionTestData>  {

        };

    }   // namespace test
}   // namespace mg

INSTANTIATE_TEST_CASE_P(VersionTest, VersionStrTest, testing::ValuesIn(versionStrTests));

TEST_P(VersionStrTest, testOStream)
{
    VersionTestData test = GetParam();

    std::ostringstream stream;
    stream << test.version;

    EXPECT_TRUE(stream.str () == test.versionStr) << "  Test String: \"" << test.versionStr << "\"\r\nExpected value: \"" << test.versionStr << "\"\r\n  Actaul value: \"" << stream.str () << "\"";
}