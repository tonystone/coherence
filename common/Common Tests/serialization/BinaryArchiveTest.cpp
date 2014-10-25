//
// Created by Tony Stone on 2/10/14.
//

#include <gtest/gtest.h>
#include "serialization/BinaryOArchive.hpp"
#include "serialization/BinaryIArchive.hpp"

using mg::serialization::BinaryOArchive;
using mg::serialization::BinaryIArchive;

namespace mg {
namespace serialization {
namespace test {

    typedef struct {
        char  const * stringValue1;
        std::time_t   timeValue1;
        char  const * stringValue2;
        std::time_t   timeValue2;
    } BinaryArchiveTestData;

    class BinaryArchiveTestObject {
    public:
        BinaryArchiveTestObject () {}
        BinaryArchiveTestObject(BinaryArchiveTestData & value)
            : mStringValue1(std::string(value.stringValue1)),  mTimeValue1(value.timeValue1), mStringValue2(std::string(value.stringValue2)),  mTimeValue2(value.timeValue2)  {}

        std::string mStringValue1;
        std::time_t mTimeValue1;
        std::string mStringValue2;
        std::time_t mTimeValue2;

    private:
        friend class mg::serialization::Access;

        template<class Archive>
        inline void serialize(Archive & archive, const unsigned int version)
        {
            archive & mStringValue1 & mTimeValue1 & mStringValue2 & mTimeValue2;
        }
    };
    inline bool operator==(const BinaryArchiveTestObject & lhs, const BinaryArchiveTestObject& rhs){
        return  lhs.mStringValue1 == rhs.mStringValue1 &&
                lhs.mTimeValue1 == rhs.mTimeValue1 &&
                lhs.mStringValue2 == rhs.mStringValue2 &&
                lhs.mTimeValue2 == rhs.mTimeValue2;
    }
    inline std::ostream & operator<<(std::ostream & os, BinaryArchiveTestObject const & obj) {
        os << "{\r\n";
        os << "\tstring Value 1 = " << obj.mStringValue1 << "\r\n";
        os << "\ttime_t Value 1 = " << obj.mTimeValue1   << "\r\n";
        os << "\tstring Value 2 = " << obj.mStringValue2 << "\r\n";
        os << "\ttime_t Value 1 = " << obj.mTimeValue2   << "\r\n";
        os << "}\r\n";
        return os;
    }

    static BinaryArchiveTestData binaryArchiveTests[] = {
            {"Test 0", 0, "", 600},
            {"Test 1", 1, "Text", 600},
            {"Test 2", 2, "~", 600},
            {"Test 3", 3, "!", 600},
            {"Test 4", 4, "@", 600},
            {"Test 5", 5, "#", 600},
            {"Test 6", 6, "$", 600},
            {"Test 7", 7, "%", 600},
            {"Test 8", 8, "^", 600},
            {"Test 9", 9, "&", 600},
            {"Test 10", 100, "*", 600},
            {"Test 11", 11, "(", 600},
            {"Test 12", 12, ")", 600},
            {"Test 13", 13, "-", 600},
            {"Test 14", 14, "_", 600},
            {"Test 15", 15, "{", 600},
            {"Test 16", 16, "}", 600},
            {"Test 17", 17, "[", 600},
            {"Test 18", 18, "]", 600},
            {"Test 19", 19, "|", 600},
            {"Test 20", 20, "\\", 600},
            {"Test 21", 21, ":", 600},
            {"Test 22", 22, ";", 600},
            {"Test 23", 23, "\"", 600},
            {"Test 24", 24, "'", 600},
            {"Test 25", 25, "<", 600},
            {"Test 26", 26, ">", 600},
            {"Test 27", 27, ",", 600},
            {"Test 28", 28, ".", 600},
            {"Test 29", 29, "?", 600},
            {"Test 30", 30, "/", 600},

            {"Test 1", std::numeric_limits<time_t>::min(), "Text", std::numeric_limits<time_t>::max()},
    };

    class BinaryArchiveTest : public testing::Test {

    };

}   // namespace test
}   // namespace serialization
}   // namespace mg

using namespace mg::serialization::test;

TEST_F(BinaryArchiveTest, testConstructionStack)
{
    std::stringbuf buffer;

    ASSERT_NO_THROW(BinaryOArchive archive(buffer));
    ASSERT_NO_THROW(BinaryIArchive archive(buffer));
}

TEST_F(BinaryArchiveTest, testConstructionPtr)
{
    std::stringbuf buffer;
    BinaryArchiveTestObject testObject;

    BinaryOArchive * binaryOArchivePtr = NULL; (void) binaryOArchivePtr;

    ASSERT_NO_THROW((binaryOArchivePtr = new BinaryOArchive(buffer)));
    ASSERT_TRUE(binaryOArchivePtr != NULL);
    ASSERT_NO_THROW(delete binaryOArchivePtr);
}

namespace mg {
namespace serialization {
namespace test {

    class BinaryArchiveSerializeTest : public BinaryArchiveTest, public testing::WithParamInterface<BinaryArchiveTestData> {

    protected:
        BinaryArchiveTestData     testData;
        BinaryArchiveTestObject   testObject;
        std::stringbuf            buffer;
        BinaryOArchive            *oArchive;

        virtual void SetUp () {
           testData   = GetParam ();
           testObject = BinaryArchiveTestObject(testData);

            oArchive = new BinaryOArchive(buffer);
        };

        virtual void TearDown () {
            delete oArchive;
        };
    };

}   // namespace test
}   // namespace serialization
}   // namespace mg

INSTANTIATE_TEST_CASE_P(BinaryArchive, BinaryArchiveSerializeTest, testing::ValuesIn(binaryArchiveTests));

TEST_P(BinaryArchiveSerializeTest, testSerialize)
{
    // Test that the << method returns the sender
    EXPECT_TRUE(&(*oArchive << testObject) == oArchive) << " Test did not return the same oArchive that was passed";
}

namespace mg {
namespace serialization {
namespace test {

    class BinaryArchiveDeserializeTest : public BinaryArchiveTest, public testing::WithParamInterface<BinaryArchiveTestData> {

    protected:
        BinaryArchiveTestData     testData;
        BinaryArchiveTestObject   oTestObject;
        BinaryArchiveTestObject   iTestObject;
        std::stringbuf            buffer;
        BinaryOArchive          * oArchive;
        BinaryIArchive          * iArchive;

        virtual void SetUp () {
            testData   = GetParam ();
            oTestObject = BinaryArchiveTestObject(testData);

            oArchive = new BinaryOArchive(buffer);
            iArchive = new BinaryIArchive(buffer);
        };

        virtual void TearDown () {
            delete oArchive;
            delete iArchive;
        };
    };

}   // namespace test
}   // namespace serialization
}   // namespace mg

INSTANTIATE_TEST_CASE_P(BinaryArchive, BinaryArchiveDeserializeTest, testing::ValuesIn(binaryArchiveTests));

TEST_P(BinaryArchiveDeserializeTest, testDeserialize)
{
    // Fill the stringbuf with the test archive
    *oArchive << oTestObject;

    // Now test the input archiver with the filled stringbuf
    EXPECT_TRUE(&(*iArchive >> iTestObject) == iArchive) << "Test did not return the same oArchive that was passed";
    EXPECT_TRUE(oTestObject == iTestObject) << "Input object " << iTestObject << "does not match output object " << oTestObject;
}



