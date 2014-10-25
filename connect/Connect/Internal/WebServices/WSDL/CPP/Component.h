//
//  Component.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__Component__
#define __MGResourceManager__Component__

#include <iostream>

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract interface in wsdl 2.0
     
     */
    class Component {

    public:
        // Construction
        Component(std::string& aName);
        ~Component();
        
        const std::string& getName();
        
        friend std::ostream& operator<<(std::ostream& os, const mg::wsdl::Component& obj);
        
    private:
        std::string name;
    };
    
} } // mg::wsdl


#endif /* defined(__MGResourceManager__Component__) */
