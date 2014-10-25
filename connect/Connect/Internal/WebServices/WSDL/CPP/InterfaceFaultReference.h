//
//  InterfaceFaultReference.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__InterfaceFaultReference__
#define __MGResourceManager__InterfaceFaultReference__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract interface in wsdl 2.0
     
     */
    class InterfaceFaultReference : public wsdl::Component {
        
    public:
        // Construction
        InterfaceFaultReference(std::string name);
        ~InterfaceFaultReference();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__InterfaceFaultReference__) */
