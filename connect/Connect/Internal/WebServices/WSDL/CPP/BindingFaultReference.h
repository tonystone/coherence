//
//  BindingFaultReference.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__BindingFaultReference__
#define __MGResourceManager__BindingFaultReference__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract binding in wsdl 2.0
     
     */
    class BindingFaultReference : public mg::wsdl::Component {
        
    public:
        // Construction
        BindingFaultReference(std::string name);
        ~BindingFaultReference();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__BindingFaultReference__) */
