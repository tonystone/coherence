//
// Created by Tony Stone on 4/30/15.
// Copyright (c) 2015 Climate Corporation. All rights reserved.
//

#ifndef CS_ASSERT_H
#define CS_ASSERT_H

#define AssertIsMainThread()  NSAssert([NSThread isMainThread], @"%@ must be executed on the main thread", NSStringFromSelector(_cmd))
#define AssertIsNotMainThreadIfCondition(condition)  NSAssert(((condition) ? ![NSThread isMainThread] : true), @"%@ can not be executed on the thread when %s is true.", NSStringFromSelector(_cmd), #condition)

#endif // CS_ASSERT_H