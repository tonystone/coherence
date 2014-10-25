//
//  BindingOperation.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__BindingOperation__
#define __MGResourceManager__BindingOperation__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract binding in wsdl 2.0
     
     */
    class BindingOperation : public mg::wsdl::Component {
        
    public:
        // Construction
        BindingOperation(std::string name);
        ~BindingOperation();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__BindingOperation__) */
