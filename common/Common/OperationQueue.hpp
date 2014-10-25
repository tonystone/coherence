//
// Created by Tony Stone on 8/24/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//


#ifndef __OperationQueue_H_
#define __OperationQueue_H_

#pragma once
#include <thread>
#include <mutex>
#include <queue>
#include <vector>
#include <future>
#include <condition_variable>

#include "LogStream.h"

namespace mg {

    /** @interface OperationQueue
    *
    */
    class OperationQueue {

    public:
        enum class ConcurrencyMode {SERIAL, CONCURRENT};

        explicit OperationQueue(ConcurrencyMode mode = ConcurrencyMode::CONCURRENT);
        virtual ~OperationQueue();

        template<class F, class... Args>
        auto submit(F&& f, Args&&... args) -> std::future<typename std::result_of<F(Args...)>::type>;

    private:
        OperationQueue() = delete;
        OperationQueue(OperationQueue & other) = delete;
        OperationQueue & operator=(OperationQueue & other) = delete;

    private:
        std::mutex mutex;
        std::condition_variable condition;

        std::vector<std::thread> threads;
        std::queue<std::function<void()>> operations;

        bool stop;
    };


    OperationQueue::OperationQueue(OperationQueue::ConcurrencyMode mode) : stop(false)
    {
        int numberOfThreads = (mode == ConcurrencyMode::CONCURRENT) ? 5 : 1;

        for(int i = 0; i < numberOfThreads; i++)
            threads.emplace_back( [this] {
                for(;;)
                {
                    std::unique_lock<std::mutex> lock(this->mutex);

                    while(!this->stop && this->operations.empty()) {
                        this->condition.wait(lock);
                    }

                    if(this->stop && this->operations.empty()) {
                        return;
                    }

                    // At this point, we've locked the
                    // operation queue and can create
                    // an operation from the entry
                    // in the queue
                    std::function<void()> operation(this->operations.front());
                    this->operations.pop();
                    lock.unlock();

                    //
                    // If we get this far, we need to
                    // execute the operation.
                    //
                    operation();
                }
            });
    }

    inline OperationQueue::~OperationQueue() {

        //
        // Wrap this in a block so we only lock the mutex
        // and set stop
        //
        {
            std::unique_lock<std::mutex> lock(mutex);
            stop = true;
        }

        condition.notify_all();
        for(int i = 0; i < threads.size(); i++)
            threads[i].join();
    }

    template<class F, class... Args>
    auto OperationQueue::submit(F&& f, Args&&... args) -> std::future<typename std::result_of<F(Args...)>::type>
    {
        typedef typename std::result_of<F(Args...)>::type return_type;

        // don't allow submitting after stopping the OperationQueue
        if(stop) {
            throw std::runtime_error("Submitting to a stopped OperationQueue");
        }

        auto task = std::make_shared< std::packaged_task<return_type()> >(
                std::bind(std::forward<F>(f), std::forward<Args>(args)...)
        );

        std::future<return_type> res = task->get_future();
        {
            std::unique_lock<std::mutex> lock(mutex);
            operations.push([task](){ (*task)(); });
        }

        condition.notify_one();
        return res;
    }

}   // namespace mg

#endif //__OperationQueue_H_
