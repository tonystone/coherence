//
//  Feature.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__Feature__
#define __MGResourceManager__Feature__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract binding in wsdl 2.0
     
     */
    class Feature : public mg::wsdl::Component {
        
    public:
        // Construction
        Feature(std::string name);
        ~Feature();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__Feature__) */
