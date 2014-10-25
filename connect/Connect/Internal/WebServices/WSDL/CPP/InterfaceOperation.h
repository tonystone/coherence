//
//  InterfaceOperation.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__InterfaceOperation__
#define __MGResourceManager__InterfaceOperation__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract interface in wsdl 2.0
     
     */
    class InterfaceOperation: public mg::wsdl::Component {
        
    public:
        // Construction
        InterfaceOperation(std::string name);
        ~InterfaceOperation();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__InterfaceOperation__) */
