//
//  CLConstents.h
//  CloudBase
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#ifndef CloudBase_CLConstents_h
#define CloudBase_CLConstents_h

typedef enum {
    instanceStateUnknown         = 0x0000,
    instanceStateOperational     = 0x0100,
    instanceStatePending         = 0x0200,
    instanceStateBooting         = 0x0300,
    instanceStateDecommissioning = 0x0400,
    instanceStateConfiguring     = 0x0500,
    instanceStateStranded        = 0x0600,
    instanceStateShuttingDown    = 0x0700,
    instanceStateStopping        = 0x0800,
    instanceStateStopped         = 0x0900,
    instanceStateInactive        = 0x1000,
    instanceStateTransitioning   = 0x1100
} CLInstanceState;


#endif
