//
//  InterfaceMessageReference.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__InterfaceMessageReference__
#define __MGResourceManager__InterfaceMessageReference__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract interface in wsdl 2.0
     
     */
    class InterfaceMessageReference : public mg::wsdl::Component {
        
    public:
        // Construction
        InterfaceMessageReference(std::string name);
        ~InterfaceMessageReference();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__InterfaceMessageReference__) */
