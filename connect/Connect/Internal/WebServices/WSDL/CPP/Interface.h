//
//  Interface.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__Interface__
#define __MGResourceManager__Interface__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract interface in wsdl 2.0
     
     */
    class Interface : public wsdl::Component {
        
        public:
            // Construction
            Interface(std::string name);
            ~Interface();

        private:
        
            
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__Interface__) */
