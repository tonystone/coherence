//
//  Description.cpp
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#include "Description.h"
#include "Component.h"

mg::wsdl::Description::Description() {
   
}

mg::wsdl::Description::~Description() {
    
}

void mg::wsdl::Description::addInterface (mg::wsdl::Interface&  anInterface) {
    interfaces.insert( std::pair<std::string, mg::wsdl::Interface &>(anInterface.getName(), anInterface) );
}

void mg::wsdl::Description::addBinding (mg::wsdl::Binding&  aBinding) {
     bindings.insert( std::pair<std::string, mg::wsdl::Binding &>(aBinding.getName(), aBinding) );
}

void mg::wsdl::Description::addService (mg::wsdl::Service& aService) {
    services.insert( std::pair<std::string, mg::wsdl::Service &>(aService.getName(), aService) );
}

void mg::wsdl::Description::addElementDeclaration (wsdl::ElementDeclaration&  anElementDeclaration) {
     elementDeclarations.insert( std::pair<std::string, wsdl::ElementDeclaration &>(anElementDeclaration.getName(), anElementDeclaration) );
}

void mg::wsdl::Description::addTypeDefinition (mg::wsdl::TypeDefinition& aTypeDefinition) {
    typeDefinitions.insert( std::pair<std::string, mg::wsdl::TypeDefinition &>(aTypeDefinition.getName(), aTypeDefinition) );
}