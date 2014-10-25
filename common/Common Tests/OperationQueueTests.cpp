//
// Created by Tony Stone on 2/12/14.
//

#include <gtest/gtest.h>
#include "OperationQueue.hpp"

using mg::OperationQueue;

namespace mg {
namespace test {

    class Operation {
        long long mRunTime;
        std::string mMessage;

    public:
        Operation(long long runTime, std::string & message) : mRunTime(runTime), mMessage(message) {}

        std::string operator()() {

            // Introduce delay.
            std::chrono::milliseconds sleepTime(mRunTime);
            std::this_thread::sleep_for(sleepTime);

            return mMessage;
        }
    };


    class OperationQueueSerialTests : public testing::Test {

    public:
        OperationQueue * queue;

    protected:
        virtual void SetUp() override {
            try {
                queue = new OperationQueue(OperationQueue::ConcurrencyMode::SERIAL);
            } catch (std::exception & e) {
                FAIL() << e.what();
            }
        }

        virtual void TearDown() override {
            delete queue;
        }
    };

}   // namespace test
}   // namespace mg

using namespace mg::test;

TEST_F(OperationQueueSerialTests, testSubmit)
{
    const std::string TestMessagePrefix = "Test Message ";

    // Hold the results of each launch
    std::vector<std::future<std::result_of<Operation()>::type>> resultFutures;

    //
    // Submit operations for each
    // test message
    //
    for (int i = 0; i < 40; i++) {
        std::string message { TestMessagePrefix+ std::to_string(i)};

        ASSERT_NO_THROW(resultFutures.push_back(queue->submit(Operation(100, message))));
    }

    //
    // Make sure they execute properly
    // by testing the result values for
    // each future.
    //
    for (int i = 0; i < resultFutures.size(); i++) {
         auto & future = resultFutures[i];

        std::result_of<Operation()>::type message = future.get();

        // ASSERT value equal the value initialized
        ASSERT_EQ(message, TestMessagePrefix + std::to_string(i));
    }

}

namespace mg {
namespace test {

    class OperationQueueConcurrentTests : public testing::Test {

    public:
        OperationQueue * queue;

    protected:
        virtual void SetUp() override {
            try {
                queue = new OperationQueue(OperationQueue::ConcurrencyMode::CONCURRENT);
            } catch (std::exception & e) {
                FAIL() << e.what();
            }
        }

        virtual void TearDown() override {
            delete queue;
        }
    };

}   // namespace test
}   // namespace mg

TEST_F(OperationQueueConcurrentTests, testSubmit)
{
    const std::string TestMessagePrefix = "Test Message ";

    // Hold the results of each launch
    std::vector<std::future<std::result_of<Operation()>::type>> resultFutures;

    //
    // Submit operations for each
    // test message
    //
    for (int i = 0; i < 40; i++) {
        std::string message { TestMessagePrefix+ std::to_string(i)};

        //
        // Introduce random delay times in the operations
        // so that we ensure that all complete in parallel
        // for concurrent queues
        //
        long long runTime = std::rand() % 100 + 1;

        ASSERT_NO_THROW(resultFutures.push_back(queue->submit(Operation(runTime, message))));
    }

    //
    // Make sure they execute properly
    // by testing the result values for
    // each future.
    //
    for (int i = 0; i < resultFutures.size(); i++) {
        auto & future = resultFutures[i];

        std::result_of<Operation()>::type message = future.get();

        // ASSERT value equal the value initialized
        ASSERT_EQ(message, TestMessagePrefix + std::to_string(i));
    }

}