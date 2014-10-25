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
#import "Role.h"
#import "Connect/MGConnect.h"
#import "Connect/MGConnectPersistentStoreCoordinator.h"

#define CSTR(nss) [nss cStringUsingEncoding: NSUTF8StringEncoding]

namespace mg {
namespace test {

    //
    // Setup specific tests
    //
    class MGConnectPersistentStoreCoordinatorTestBase {

    public:

        NSManagedObjectModel         * model;
        NSPersistentStoreCoordinator * persistentStoreCoordinator;

    protected:

        void SetUp() {

            try {
                NSURL * momURL = [[NSBundle mainBundle] URLForResource: @"MGConnectTestModel" withExtension: @"mom"];
                model = [[NSManagedObjectModel alloc] initWithContentsOfURL: momURL];

                persistentStoreCoordinator = [[MGConnectPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
            } catch (...) {
                FAIL() << "Unknown exception caught in SetUp.";
            }
        }

        void TearDown() {

            try {
                persistentStoreCoordinator = nil;
                model = nil;
            } catch (...) {
                FAIL() << "Unknown exception caught in TearDown.";
            }
        }
    };

    class MGConnectPersistentStoreCoordinatorTest
            : public MGConnectPersistentStoreCoordinatorTestBase, public testing::Test {

    protected:

        virtual void SetUp() override {
            MGConnectPersistentStoreCoordinatorTestBase::SetUp();
        }

        virtual void TearDown() override {
            MGConnectPersistentStoreCoordinatorTestBase::TearDown();
        }
    };

}   // namespace test
}   // namespace mg

using namespace mg::test;

//
// Free form tests
//
TEST_F(MGConnectPersistentStoreCoordinatorTest, testGetManagedObjectModel) {

    //
    // Test that the same model that went in, comes out.
    //
    ASSERT_TRUE([[persistentStoreCoordinator managedObjectModel] isEqual: model]);
}

TEST_F(MGConnectPersistentStoreCoordinatorTest, testAttacheContext) {

    NSManagedObjectContext * context = [[NSManagedObjectContext alloc] init];

    //
    // Can we attache a context to the persistent store without error.
    //
    [context setPersistentStoreCoordinator: persistentStoreCoordinator];
}

TEST_F(MGConnectPersistentStoreCoordinatorTest, testLocking) {

    //
    // Can we lock and unlock the store
    //
    EXPECT_NO_THROW([persistentStoreCoordinator lock]);
    EXPECT_NO_THROW([persistentStoreCoordinator unlock]);

    ASSERT_TRUE([persistentStoreCoordinator tryLock]);

    EXPECT_NO_THROW([persistentStoreCoordinator unlock]);
}


namespace mg {
namespace test {

    typedef struct {
        NSString     * storeType;
        NSString     * storeName;
        NSDictionary * storeOptions;
    } PersistentStoreCoordinatorTestData;

    void PrintTo(const PersistentStoreCoordinatorTestData& obj, ::std::ostream* os) {
        *os << [obj.storeType cStringUsingEncoding: NSUTF8StringEncoding] << " (" << [obj.storeName  cStringUsingEncoding: NSUTF8StringEncoding] << ")";
    }

    static PersistentStoreCoordinatorTestData persistentStoreTypes[] = {

            // CoreData store types
            {NSInMemoryStoreType, @"NSInMemoryStoreType.bin", @{}},
            {NSSQLiteStoreType,   @"NSSQLiteStoreType.sqlite", @{}},
            {NSBinaryStoreType,   @"NSBinaryStoreType.bin", @{}},
            {NSXMLStoreType,      @"NSXMLStoreType.xml", @{}},

            // Connect store types
            //
            // This store is not implemented yet
            // Uncomment when it is implemented.
//          //
//           {MGSQLiteStoreType,   @"MGSQLiteStoreType.sqlite", @{}},
            {MGInMemoryStoreType, @"MGInMemoryStoreType.bin", @{}},

    };

    class MGConnectPersistentStoreCoordinatorStoreTypeTest
            : public MGConnectPersistentStoreCoordinatorTestBase, public testing::TestWithParam<PersistentStoreCoordinatorTestData> {

    protected:
        PersistentStoreCoordinatorTestData   testData;
        NSURL                              * storeUrl;

    protected:

        virtual void SetUp() override {

            try {
                testData = GetParam();

                NSArray  * paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString * storePath = [[paths objectAtIndex:0] stringByAppendingPathComponent: testData.storeName];

                storeUrl  = [NSURL fileURLWithPath: storePath];

                removeExistingFile(storeUrl);
            } catch (...) {
                FAIL() << "Unknown exception caught in SetUp.";
            }
            MGConnectPersistentStoreCoordinatorTestBase::SetUp();
        }

        virtual void TearDown() override {

            storeUrl = nil;

            MGConnectPersistentStoreCoordinatorTestBase::TearDown();
        }

    private:
        void removeExistingFile (NSURL * fileURL) {
            NSFileManager * fileManager = [NSFileManager defaultManager];

            if ([fileManager fileExistsAtPath: [fileURL path]]) {
                NSError * error = nil;

                [fileManager removeItemAtURL: fileURL error: &error];
            }
        }
    };

}   // namespace test
}   // namespace mg


//
// Data driven tests
//
INSTANTIATE_TEST_CASE_P(Tests, MGConnectPersistentStoreCoordinatorStoreTypeTest, testing::ValuesIn(persistentStoreTypes));


TEST_P(MGConnectPersistentStoreCoordinatorStoreTypeTest, testAddPersistentStoreWithType) {

    NSError           * error           = nil;
    NSPersistentStore * persistentStore = nil;
    //
    // This should not throw an exception
    // but should return a persistent store.
    //
    EXPECT_NO_THROW(persistentStore = [persistentStoreCoordinator addPersistentStoreWithType: testData.storeType configuration:nil URL: storeUrl options: testData.storeOptions error: &error]);

    ASSERT_TRUE(error == nil) << CSTR([error localizedDescription]);
    ASSERT_TRUE(persistentStore != nil);

    //
    // Now make sure we can remove the
    // persistentStore as well.
    //
    EXPECT_NO_THROW([persistentStoreCoordinator removePersistentStore: persistentStore error: &error]);

    ASSERT_TRUE(error == nil) << CSTR([error localizedDescription]);
}

TEST_P(MGConnectPersistentStoreCoordinatorStoreTypeTest, testURLForPersistentStore) {

    NSError           * error           = nil;
    NSPersistentStore * persistentStore = nil;
    //
    // This should not throw an exception
    // but should return a persistent store.
    //
    EXPECT_NO_THROW(persistentStore = [persistentStoreCoordinator addPersistentStoreWithType: testData.storeType configuration:nil URL: storeUrl options: testData.storeOptions error: &error]);

    ASSERT_TRUE( error == nil) << CSTR([error localizedDescription]);
    ASSERT_TRUE([[persistentStoreCoordinator URLForPersistentStore:persistentStore] isEqual: storeUrl]);
}

TEST_P(MGConnectPersistentStoreCoordinatorStoreTypeTest, testMetaData) {

    static NSDictionary * inputMetadata = @{@"TestKey 1": @1,
                                            @"TestKey 2": @"two"};

    NSError * error = nil;
    
    NSPersistentStore * persistentStore  = [persistentStoreCoordinator addPersistentStoreWithType: testData.storeType configuration:nil URL: storeUrl options: testData.storeOptions error: &error];
    
    [persistentStoreCoordinator setMetadata: inputMetadata forPersistentStore: persistentStore];
    
    NSDictionary * outputMetadata = [persistentStoreCoordinator metadataForPersistentStore: persistentStore];
    
    // Make sure they are all in the outputMetadata
    for (NSString * key in inputMetadata) {
        NSObject * inputValue = inputMetadata[key];
        
        ASSERT_TRUE(outputMetadata[key] != nil);
        ASSERT_TRUE([outputMetadata[key] isEqual: inputValue]);
    }
}

TEST_P(MGConnectPersistentStoreCoordinatorStoreTypeTest, testExecuteRequest) {

    typedef struct {
        NSString * name;
        NSString * ein;
    } CompanyTestData;

    typedef struct {
        NSString * first;
        NSString * last;
        NSString * ssn;
        int32_t    employeeNumber;
    } EmployeeTestData;

    typedef struct {
        NSString * name;
    } RoleTestData;
    
    static CompanyTestData testCompanies[] = {
            {@"Company #1", @"11-1111111"},
            {@"Company #2", @"22-2222222"},
            {@"Company #3", @"33-3333333"},
            {@"Company #4", @"44-4444444"},
            {@"~!@#$%^&*()_+`-={}[]|:;'<>,.?/'", @"~!-@#$%^&*"},
    };
    
    static EmployeeTestData testEmployees[] = {
        {@"Employee", @"One", @"111-11-1111", 1},
        {@"Employee", @"Two", @"222-22-2222", 2},
    };
    
    static RoleTestData testRoles[] = {
        @"Role 1",
        @"Role 2",
    };

    NSError * error   = nil;

    // Add a persistent store
    [persistentStoreCoordinator addPersistentStoreWithType: testData.storeType configuration:nil URL: storeUrl options: testData.storeOptions error: &error];

    NSManagedObjectContext * context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator: persistentStoreCoordinator];

    NSMutableArray * roles = [[NSMutableArray alloc] init];
    
    for (RoleTestData roleData : testRoles) {
        Role * insertedRole = [NSEntityDescription insertNewObjectForEntityForName: @"Role" inManagedObjectContext: context];
        
        [insertedRole setName: roleData.name];
        
        [roles addObject: insertedRole];
    }
    
    for (CompanyTestData companyData : testCompanies) {

        //
        // Insert a new company
        //
        Company * insertedCompany = [NSEntityDescription insertNewObjectForEntityForName: @"Company" inManagedObjectContext: context];

        [insertedCompany setName: companyData.name];
        [insertedCompany  setEin: companyData.ein];
        
        //
        // Add some employee and relate them to the company
        //
        for (EmployeeTestData employeeData : testEmployees) {

            //
            // Insert a new employee
            //
            Employee * insertedEmployee = [NSEntityDescription insertNewObjectForEntityForName: @"Employee" inManagedObjectContext: context];

            [insertedEmployee          setFirst: employeeData.first];
            [insertedEmployee           setLast: employeeData.last];
            [insertedEmployee            setSsn: employeeData.ssn];
            [insertedEmployee setEmployeeNumber: employeeData.employeeNumber];

            [insertedEmployee setCompany: insertedCompany];
            
            for (Role * role in roles) {
                [role addEmployeesObject: insertedEmployee];
            }
        }

        ASSERT_TRUE([context save: &error]);

        NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity: [[model entitiesByName] objectForKey:@"Company"]];

        NSArray * results = nil;

        ASSERT_TRUE((results = [context executeFetchRequest: fetch error: &error])) << "Failed to execute fetch on Company object: " << [error localizedDescription] << std::endl;
        ASSERT_EQ([results count], 1);

        Company * resultCompany = [results lastObject];

        ASSERT_TRUE([[resultCompany name] isEqualToString: [insertedCompany name]]);
        ASSERT_TRUE([[resultCompany ein]  isEqualToString: [insertedCompany ein]]);

        [context deleteObject: resultCompany];

        ASSERT_TRUE([context save: &error]);
    }

}

