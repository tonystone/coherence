//
//  InterfaceFault.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__InterfaceFault__
#define __MGResourceManager__InterfaceFault__

#include <iostream>

#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract interface in wsdl 2.0
     
     */
    class InterfaceFault : public wsdl::Component {
        
    public:
        // Construction
        InterfaceFault(std::string name);
        ~InterfaceFault();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__InterfaceFault__) */
