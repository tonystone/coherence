//
//  TypeDefinition.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__TypeDefinition__
#define __MGResourceManager__TypeDefinition__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract binding in wsdl 2.0
     
     */
    class TypeDefinition : public mg::wsdl::Component {
        
    public:
        // Construction
        TypeDefinition(std::string name);
        ~TypeDefinition();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__TypeDefinition__) */
