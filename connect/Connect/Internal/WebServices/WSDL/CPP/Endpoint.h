//
//  Endpoint.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__Endpoint__
#define __MGResourceManager__Endpoint__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract binding in wsdl 2.0
     
     */
    class Endpoint : public mg::wsdl::Component {
        
    public:
        // Construction
        Endpoint(std::string name);
        ~Endpoint();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__Endpoint__) */
