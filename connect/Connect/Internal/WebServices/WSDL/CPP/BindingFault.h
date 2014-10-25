//
//  BindingFault.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__BindingFault__
#define __MGResourceManager__BindingFault__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract binding in wsdl 2.0
     
     */
    class BindingFault : public mg::wsdl::Component {
        
    public:
        // Construction
        BindingFault(std::string name);
        ~BindingFault();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__BindingFault__) */
