//
//  Service.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__Service__
#define __MGResourceManager__Service__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract binding in wsdl 2.0
     
     */
    class Service : public mg::wsdl::Component {
        
    public:
        // Construction
        Service(std::string name);
        ~Service();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__Service__) */
