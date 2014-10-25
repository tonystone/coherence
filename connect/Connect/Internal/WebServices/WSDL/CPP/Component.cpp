//
//  Component.cpp
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#include "Component.h"

mg::wsdl::Component::Component(std::string& aName) : name() {
    name = aName;
}

mg::wsdl::Component::~Component() {

}

const std::string&  mg::wsdl::Component::getName() {
    return name;
}

std::ostream& mg::wsdl::operator<<(std::ostream& os, const mg::wsdl::Component& obj) {
    
    os << "Component: " << obj.name << std::endl;
    
    return os;
}