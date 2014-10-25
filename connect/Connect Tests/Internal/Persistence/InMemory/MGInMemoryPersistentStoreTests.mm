//
//  MGInMemoryPersistentStoreTests.m
//  MGInMemoryPersistentStoreTests
//
//  Created by Tony Stone on 7/2/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#include <gtest/gtest.h>

#import "Company.h"
#import "Person.h"
#import "Employee.h"
#import "Connect/MGConnect.h"

namespace mg {
namespace test {

    //
    // Setup specific tests
    //
    class MGInMemoryPersistentStoreTestBase {

    public:

        NSManagedObjectModel         * model;
        NSPersistentStoreCoordinator * persistentStoreCoordinator;
        NSManagedObjectContext       * context;

    protected:

        void SetUp() {

            try {
                NSError *error = nil;

                NSURL * momURL = [[NSBundle mainBundle] URLForResource: @"MGConnectTestModel" withExtension: @"mom"];
                model = [[NSManagedObjectModel alloc] initWithContentsOfURL: momURL];

                persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];

                NSArray  * paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString * storePath = [[paths objectAtIndex:0] stringByAppendingPathComponent: @"MGConnectTestModel.bin"];

                NSURL    * storeUrl  = [NSURL fileURLWithPath: storePath];

                NSFileManager * fileManager = [NSFileManager defaultManager];

                if ([fileManager fileExistsAtPath: [storeUrl path]]) {
                    [fileManager removeItemAtURL: storeUrl error: &error];
                }

                NSString * storeType = MGInMemoryStoreType;

                if (![persistentStoreCoordinator addPersistentStoreWithType: storeType configuration:nil URL: storeUrl options: nil error:&error]) {
                    FAIL() << "Failed to create persistent store: " << [error localizedDescription] << " " << [error userInfo] << std::endl;
                }

                context = [[NSManagedObjectContext alloc] init];
                [context setPersistentStoreCoordinator: persistentStoreCoordinator];

            } catch (...) {
                FAIL() << "Unknown exception caught in SetUp.";
            }
        }

        void TearDown() {

            try {
                NSError * error = nil;

                for (NSPersistentStore * persistentStore in [persistentStoreCoordinator persistentStores]) {
                    NSURL * storeUrl = [persistentStore URL];

                    [persistentStoreCoordinator removePersistentStore: persistentStore error: &error];

                    NSFileManager * fileManager = [NSFileManager defaultManager];

                    if ([fileManager fileExistsAtPath: [storeUrl path]]) {
                        [fileManager removeItemAtURL: storeUrl error: &error];
                    }

                    context = nil;
                    persistentStoreCoordinator = nil;
                    model = nil;
                }
            } catch (...) {
                FAIL() << "Unknown exception caught in TearDown.";
            }
        }

        void loadTestData() {

        }
    };

    class MGInMemoryPersistentStoreTest
            : public MGInMemoryPersistentStoreTestBase, public testing::Test {

    protected:

        virtual void SetUp() override {
            MGInMemoryPersistentStoreTestBase::SetUp();
        }

        virtual void TearDown() override {
            MGInMemoryPersistentStoreTestBase::TearDown();
        }
    };

}   // namespace test
}   // namespace mg

using namespace mg::test;

TEST_F(MGInMemoryPersistentStoreTest, testEmptyRead) {

    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity: [[model entitiesByName] objectForKey:@"Company"]];

    NSArray * results = nil;
    NSError * error   = nil;

    ASSERT_TRUE((results = [context executeFetchRequest: fetch error: &error])) << "Failed to execute fetch on Company object: " << [error localizedDescription] << std::endl;
    ASSERT_EQ([results count], 0);
}

namespace mg {
namespace test {

    typedef struct {
        const char * name;
        const char * ein;
    } CompanyTestData;

    void PrintTo(const CompanyTestData& data, ::std::ostream* os) {
        *os << "name: " << data.name << " ein: " << data.ein;
    }

    static CompanyTestData testData[] = {
            {"Company #1", "11-1111111"},
            {"Company #2", "22-2222222"},
            {"Company #3", "33-3333333"},
            {"Company #4", "44-4444444"},
            {"~!@#$%^&*()_+`-={}[]|:;'<>,.?/'", "~!-@#$%^&*"},
    };

    //
    // Setup specific tests
    //
    class MGInMemoryPersistentStoreCompanyTest : public MGInMemoryPersistentStoreTestBase, public testing::TestWithParam<mg::test::CompanyTestData>  {

    protected:

        virtual void SetUp() override {
            MGInMemoryPersistentStoreTestBase::SetUp();
        }

        virtual void TearDown() override {
            MGInMemoryPersistentStoreTestBase::TearDown();
        }
    };

}   // namespace test
}   // namespace mg

using namespace mg::test;

INSTANTIATE_TEST_CASE_P(Tests, MGInMemoryPersistentStoreCompanyTest, testing::ValuesIn(testData));

TEST_P(MGInMemoryPersistentStoreCompanyTest, testWrite) {

    CompanyTestData testData = GetParam();

    NSError * error   = nil;

    // Insert a new company
    Company * insertedCompany = [NSEntityDescription insertNewObjectForEntityForName: @"Company" inManagedObjectContext: context];

    [insertedCompany setName: [NSString stringWithCString: testData.name encoding: NSUTF8StringEncoding]];
    [insertedCompany  setEin: [NSString stringWithCString: testData.ein  encoding: NSUTF8StringEncoding]];

    ASSERT_TRUE([context save: &error]);

    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity: [[model entitiesByName] objectForKey:@"Company"]];

    NSArray * results = nil;

    ASSERT_TRUE((results = [context executeFetchRequest: fetch error: &error])) << "Failed to execute fetch on Company object: " << [error localizedDescription] << std::endl;
    ASSERT_EQ([results count], 1);

    Company * resultCompany = [results lastObject];

    ASSERT_TRUE([[resultCompany name] isEqualToString: [insertedCompany name]]);
    ASSERT_TRUE([[resultCompany ein]  isEqualToString: [insertedCompany ein]]);
}