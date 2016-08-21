//
//  MGAssert.h
//  MGConnect
//
//  Created by Tony Stone on 4/3/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef MGConnect_MGAssert_h
#define MGConnect_MGAssert_h


#define MGAssertIsMainThread()                   NSAssert([NSThread isMainThread],  @"Thread Confinement Exception: method %@ : %@ called on a background thread, this method can only be called from the main thread.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#define MGAssertIsNotMainThread()                NSAssert(![NSThread isMainThread], @"Thread Confinement Exception: method %@ : %@ called on the main thread, this method can only be called from a background thread.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#define MGAssertIsNotMainThreadIfCondition(cond) NSAssert(((cond) ? ![NSThread isMainThread] : TRUE), @"Thread Confinement Exception: method %@ : %@ called on the main thread, this method can only be called from a background thread when " #cond " is TRUE.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));


#endif
