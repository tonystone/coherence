//
//  ElementDeclaration.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__ElementDeclaration__
#define __MGResourceManager__ElementDeclaration__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract binding in wsdl 2.0
     
     */
    class ElementDeclaration : public mg::wsdl::Component {
        
    public:
        // Construction
        ElementDeclaration(std::string name);
        ~ElementDeclaration();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__ElementDeclaration__) */
