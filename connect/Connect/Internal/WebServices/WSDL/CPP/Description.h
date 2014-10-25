//
//  Description.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__Description__
#define __MGResourceManager__Description__

#include <iostream>
#include <map>
#include "Interface.h"
#include "Binding.h"
#include "Service.h"
#include "ElementDeclaration.h"
#include "TypeDefinition.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract interface in wsdl 2.0
     
     */
    class Description {
        
    public:
        std::map<std::string, mg::wsdl::Interface> &          getInterfaces();
        std::map<std::string, mg::wsdl::Binding> &            getBindings();
        std::map<std::string, mg::wsdl::Service> &            getServices();
        std::map<std::string, mg::wsdl::ElementDeclaration> & getElementDeclarations();
        std::map<std::string, mg::wsdl::TypeDefinition> &     getTypeDefinitions();
        
        // protected:
        // Construction
        Description();
        ~Description();
        
        void addInterface           (mg::wsdl::Interface&           anInterface);
        void addBinding             (mg::wsdl::Binding&             aBinding);
        void addService             (mg::wsdl::Service&             aService);
        void addElementDeclaration  (mg::wsdl::ElementDeclaration&  anElementDeclaration);
        void addTypeDefinition      (mg::wsdl::TypeDefinition&      aTypeDefinition);
        
    private:
        std::map<std::string, mg::wsdl::Interface &>          interfaces;
        std::map<std::string, mg::wsdl::Binding &>            bindings;
        std::map<std::string, mg::wsdl::Service &>            services;
        std::map<std::string, mg::wsdl::ElementDeclaration &> elementDeclarations;
        std::map<std::string, mg::wsdl::TypeDefinition &>     typeDefinitions;
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__Description__) */
