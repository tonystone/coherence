//
//  BindingMessageReference.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__BindingMessageReference__
#define __MGResourceManager__BindingMessageReference__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract binding in wsdl 2.0
     
     */
    class BindingMessageReference : public mg::wsdl::Component {
        
    public:
        // Construction
        BindingMessageReference(std::string name);
        ~BindingMessageReference();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__BindingMessageReference__) */
