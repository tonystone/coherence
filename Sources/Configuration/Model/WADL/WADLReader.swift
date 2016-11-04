//
//  WADLReader.swift
//  Pods
//
//  Created by Tony Stone on 8/26/16.
//
//

import Swift


/// TODO: When swift fixes the limitation on nested types in generics, this should move inside XMLNodeCollectionErrors and renamed Errors
fileprivate enum XMLNodeCollectionErrors : Error {
    case ConstraintViolation(String)
}

/// Special collection that will aggragate in order elements matching a criteria
fileprivate class XMLNodeCollection<T: XMLNode> {
    private var nodes: [T] = []
    private var index: Int
    
    init(nodes: [XMLNode]) {
        
        for node in nodes {
            if let node = node as? T {
                self.nodes.append(node)
            }
        }
        self.index = 0
    }
    
    func accept(min: Int = 0, max: Int = 0, matching: @autoclosure (_ node: T) -> Bool = true, body: (T) throws -> Void) throws {
        var processed = 0
        
        while index < nodes.count {
            let node = nodes[index]
            
            if matching(node) {
                
                try body(node)
                
                index = index + 1
                processed = processed + 1
            } else {
                break
            }
        }
        
        if processed <  min {
            throw XMLNodeCollectionErrors.ConstraintViolation("Min constraint of \(min) not satisfied")
        }
        if max != 0 && processed > max {
            throw XMLNodeCollectionErrors.ConstraintViolation("Max constraint of \(max) exceeded")
        }
    }
}


class WADLReader {
    
    public enum Errors : Error {
        case invalidWADL(String)
        case duplicateElementID(String)
    }
    
    /// Maps into the referencable elements for resolution later.
    private var elementsByID: [String : WADLElement] = [:]
    
    /// Register an element by ID for second pass resolution of references
    private func registerElement(id: String, element: WADLElement) throws {
        
        if self.elementsByID[id] != nil {
            throw Errors.duplicateElementID("Duplicate element id \(id) found.")
        }
        self.elementsByID[id] = element
    }
    
    func read(stream stream: InputStream) throws -> WADLApplication {
        
        /// parse the XML into an XMLDocument object first
        let document = try XMLReader.document(stream: stream)
        
        /// Now parse the XMLDocument object
        ///
        /// In this case we only care about the application element, we ignore all others.
        ///
        for node in document.children {
            
            if let element = node as? XMLElement , element.name == "application" {
                
                /// The parent of this application Element is always nil because Application has no parent in our model.
                let application = try self.application(element, parent: nil)
                
                /// Resolve references
                
                return application
            }
        }
        /// If no Application Element this is an error
        throw Errors.invalidWADL("Invalid wadl...")
    }
    
    ///
    /// WADL Application Element
    ///
    private func application(_ element: XMLElement, parent: WADLElement?) throws -> WADLApplication {
        
        let application = WADLApplication(parent: parent)
        
        /// At this level we collect the resources elements without processing yet
        /// They will be processed in a different order than they appear so that
        /// we can make sure referencable items are registered before they are required
        ///
        var resourcesElements:      [XMLElement] = []
        var resourceTypeElements:   [XMLElement] = []
        var methodElements:         [XMLElement] = []
        var representationElements: [XMLElement] = []
        var paramElements:          [XMLElement] = []
        
        let elements = XMLNodeCollection<XMLElement>(nodes: element.children)
        
        /// Doc elements
        try elements.accept(min: 0, matching: element.name == "doc") {
            application.docs.append(try self.doc($0, parent: application))
        }
        
        try elements.accept(min: 0, max: 1, matching: element.name == "grammars") {
            application.grammars = try self.grammars($0, parent: application)
        }
        
        try elements.accept(min: 0, matching: element.name == "resources") {
            resourcesElements.append($0)
        }
        
        try elements.accept(min: 0, matching: element.name == "resource_type") {
            resourceTypeElements.append($0)
        }
        
        try elements.accept(min: 0, matching: element.name == "method") {
            methodElements.append($0)
        }
        
        try elements.accept(min: 0, matching: element.name == "representation") {
            representationElements.append($0)
        }
        
        try elements.accept(min: 0, matching: element.name == "param") {
            paramElements.append($0)
        }
        
        // otherElements
        try elements.accept(min: 0) {
            application.otherElements.append($0)
        }
    
        // Process in this order: Params, Methods, Representations, ResourceType
        for paramElement in paramElements {
            application.params.append(try self.param(paramElement, parent: application))
        }
        for methodElement in methodElements {
            application.methods.append(try self.method(methodElement, parent: application))
        }
        for representationElement in representationElements {
            application.representations.append(try self.representation(representationElement, parent: application))
        }
        for resourceTypeElement in resourceTypeElements {
            application.resourceTypes.append(try self.resourceType(resourceTypeElement, parent: application))
        }
        
        // Now process the resources elements
        for resourcesElement in resourcesElements {
            application.resources.append(try self.resources(resourcesElement, parent: application))
        }
        
        return application
    }
    
    /*
        WADL Doc Element
     */
    private func doc(_ element: XMLElement, parent: WADLElement?) throws -> WADLDoc {
        
        guard let lang = element.attributes["xml:lang"] else {
            throw Errors.invalidWADL("Doc element missing \"lang\" attribute")
        }
        guard let title = element.attributes["title"] else {
            throw Errors.invalidWADL("Doc element missing \"title\" attribute")
        }

        let textNodes = XMLNodeCollection<XMLText>(nodes: element.children)
        var text: String? = nil
        
        try textNodes.accept(min: 0, max: 1) {
            text = $0.data
        }
        return WADLDoc(lang: lang, title: title, text: text, parent: parent)

    }
    
    /*
        WADL Grammers Element
     */
    private func grammars(_ element: XMLElement, parent: WADLElement?) throws -> WADLGrammars {
    
        return WADLGrammars(parent: parent)
    }
    
    /*
        WADL Resources Element
     */
    private func resources(_ element: XMLElement, parent: WADLElement?) throws -> WADLResources {
        
        guard let baseString = element.attributes["base"] else {
            throw Errors.invalidWADL("Resources element missing \"base\" attribute")
        }
        guard let base = URL(string: baseString) else {
            throw Errors.invalidWADL("Incorrect format for \"base\" attribute")
        }
        
        let resources = WADLResources(base: base, parent: parent)
        
        // Collect all the child elements for this resources element
        let elements = XMLNodeCollection<XMLElement>(nodes: element.children)
        
        try elements.accept(min: 0, matching: element.name == "doc") {
            resources.docs.append(try self.doc($0, parent: resources))
        }
        
        try elements.accept(min: 0, matching: element.name == "resource") {
            resources.resources.append(try self.resource($0, parent: resources))
        }
        
        // otherElements
        try elements.accept(min: 0) {
            resources.otherElements.append($0)
        }
        
        return resources
    }

    
    /*
        WADL Resource Element
     */
    private func resource(_ element: XMLElement, parent: WADLElement?) throws -> WADLResource {
        
        // Attributes
        var queryType: WADLMediaType? = nil
        
        if let queryTypeString = element.attributes["queryType"] {
           queryType = WADLMediaType(rawValue: queryTypeString)
        }

        let resource = WADLResource(id: element.attributes["id"], path: element.attributes["path"], type: element.attributes["type"], queryType: queryType, parent: parent)
        
        // Collect all the child elements for this element
        let elements = XMLNodeCollection<XMLElement>(nodes: element.children)
        
        try elements.accept(min: 0, matching: element.name == "doc") {
            resource.docs.append(try self.doc($0, parent: resource))
        }
        
        try elements.accept(min: 0, matching: element.name == "param") {
            resource.params.append(try self.param($0, parent: resource))
        }
        
        try elements.accept(min: 0, matching: element.name == "method") {
            resource.methods.append(try self.method($0, parent: resource))
        }
        
        try elements.accept(min: 0, matching: element.name == "resource") {
            resource.resources.append(try self.resource($0, parent: resource))
        }
        
        // otherElements
        try elements.accept(min: 0) {
            resource.otherElements.append($0)
        }
        
        // Register this element by ID so it can be looked up later
        if let id = resource.id {
            try self.registerElement(id: id, element: resource)
        }
        
        return resource
    }
    
    /*
        WADL ResourceType Element
     */
    private func resourceType(_ element: XMLElement, parent: WADLElement?) throws -> WADLResourceType {
        
        guard let id = element.attributes["id"] else {
           throw Errors.invalidWADL("ResourceType element missing required \"id\" attribute")
        }
        
        let resourceType = WADLResourceType(id: id, parent: parent)
        
        // Collect all the child elements for this element
        let elements = XMLNodeCollection<XMLElement>(nodes: element.children)
        
        try elements.accept(min: 0, matching: element.name == "doc") {
            resourceType.docs.append(try self.doc($0, parent: resourceType))
        }
        
        // Zero or more param elements (see section 2.12 ) with one of the following values for its style attribute:
        //      query
        //          Specifies a URI query parameter for all child method elements of the resource type.
        //      header
        //          Specifies a HTTP header for use in the request part of all child method elements of the resource type.
        //
        try elements.accept(min: 0, matching: element.name == "param") {
            
            let param = try self.param($0, parent: resourceType)
            
            if ![WADLParam.Style.query, WADLParam.Style.header].contains(param.style) {
                throw Errors.invalidWADL("Param elemenst within a resourceType can only be one of style \'query\' or \'heder\'.")
            }
            resourceType.params.append(param)
        }
        
        try elements.accept(min: 0, matching: element.name == "method") {
            resourceType.methods.append(try self.method($0, parent: resourceType))
        }
        
        try elements.accept(min: 0, matching: element.name == "resource") {
            resourceType.resources.append(try self.resource($0, parent: resourceType))
        }
        
        // Register this element by ID so it can be looked up later
        try self.registerElement(id: id, element: resourceType)
        
        return resourceType
    }
    
    /*
        WADL Method Element
     */
    private func method(_ element: XMLElement, parent: WADLElement?) throws -> WADLMethod {
  
        if var href = element.attributes["href"] {
            
            // Trim the first charactor and check that it is a # which means its an intra-document reference
            guard href.remove(at: href.startIndex) == "#" else {
                throw Errors.invalidWADL("Invalid reference \(href), only intra-document references are supported at this point.")
            }
            
            guard let method = elementsByID[href] as? WADLMethod else {
                throw Errors.invalidWADL("Method with id \(href) not defined.")
            }
            
            return method
        } else {
            
            guard let name = element.attributes["name"] else {
                throw Errors.invalidWADL("Method element missing \"name\" attribute")
            }
        
            let id = element.attributes["id"]
        
            // WADL Spec:
            //
            // An identifier for the method, required for globally defined methods,
            // not allowed on locally embedded methods. Methods are identified by an
            // XML ID and are referred to using a URI reference.
            
            //
            // Note: most implementations including Epigee and Java Jersey framework
            //       allow an id for all method elements so we are relaxing the 
            //       restriction the WADL spec specifies.
            //
            if parent is WADLApplication {
                guard id != nil else {
                   throw Errors.invalidWADL("id attribute is required for globally defined Method elements.")
                }
            }
            let method = WADLMethod(name: name, id: id, parent: parent)
            
            // Collect all the child elements for this element
            let elements = XMLNodeCollection<XMLElement>(nodes: element.children)
            
            try elements.accept(min: 0, matching: element.name == "doc") {
                method.docs.append(try self.doc($0, parent: method))
            }
            
            try elements.accept(min: 1, max: 1,  matching: element.name == "request") {
                method.request = try self.request($0, parent: method)
            }
            
            try elements.accept(min: 0, matching: element.name == "response") {
                method.responses.append(try self.response($0, parent: method))
            }
            
            // otherElements
            try elements.accept(min: 0) {
                method.otherElements.append($0)
            }
            
            // Register this element by ID so it can be looked up later
            if let id = method.id {
                try self.registerElement(id: id, element: method)
            }
            
            return method
        }
    }
    
    /*
        WADL Request Element
     */
    private func request(_ element: XMLElement, parent: WADLElement?) throws -> WADLRequest {
        
        let request = WADLRequest(parent: parent)
        
        // Collect all the child elements for this element
        let elements = XMLNodeCollection<XMLElement>(nodes: element.children)
        
        try elements.accept(min: 0, matching: element.name == "doc") {
            request.docs.append(try self.doc($0, parent: request))
        }
        
        try elements.accept(min: 0, matching: element.name == "param") {
            request.params.append(try self.param($0, parent: request))
        }
        
        try elements.accept(min: 0, matching: element.name == "representation") {
            request.representations.append(try self.representation($0, parent: request))
        }
        
        // otherElements
        try elements.accept(min: 0) {
            request.otherElements.append($0)
        }
        
        return request
    }
    
    /*
        WADL Request Element
     */
    private func response(_ element: XMLElement, parent: WADLElement?) throws -> WADLResponse {
        
        let response = WADLResponse(status: element.attributes["status"], parent: parent)
        
        // Collect all the child elements for this element
        let elements = XMLNodeCollection<XMLElement>(nodes: element.children)
        
        try elements.accept(min: 0, matching: element.name == "doc") {
            response.docs.append(try self.doc($0, parent: response))
        }
        
        /// Zero or more param elements (see section 2.12 ) with a value of 'header' for their style attribute, each of which specifies the details of a HTTP header for the response
        try elements.accept(min: 0, matching: element.name == "param") {
            
            let param = try self.param($0, parent: response)
            
            if ![WADLParam.Style.header].contains(param.style) {
                throw Errors.invalidWADL("Param elemenst within a response can only be one of style \'heder\'.")
            }
            
            response.params.append(param)
        }
        
        try elements.accept(min: 0, matching: element.name == "representation") {
            response.representations.append(try self.representation($0, parent: response))
        }
        
        // otherElements
        try elements.accept(min: 0) {
            response.otherElements.append($0)
        }
        
        return response
    }
    
    /*
        WADL Representation Element
     */
    private func representation(_ element: XMLElement, parent: WADLElement?) throws -> WADLRepresentation {
        
        // If this is a reference, search for the element to find the global instance
        if var href = element.attributes["href"] {
            
            // Trim the first charactor and check that it is a # which means its an intra-document reference
            guard href.remove(at: href.startIndex) == "#" else {
                throw Errors.invalidWADL("Invalid reference \(href), only intra-document references are supported at this point.")
            }

            guard let representation = elementsByID[href] as? WADLRepresentation else {
                throw Errors.invalidWADL("Representation with id \(href) not defined.")
            }
            return representation
            
        } else {
            
            guard let mediaType = element.attributes["mediaType"] else {
                throw Errors.invalidWADL("Representation element missing required \"mediaType\" attribute")
            }
            
            let representation = WADLRepresentation(mediaType: WADLMediaType(rawValue: mediaType), id: element.attributes["id"], element: element.attributes["element"], profile: element.attributes["profile"], parent: parent)
            
            // Collect all the child elements for this element
            let elements = XMLNodeCollection<XMLElement>(nodes: element.children)
            
            try elements.accept(min: 0, matching: element.name == "doc") {
                representation.docs.append(try self.doc($0, parent: representation))
            }
            
            try elements.accept(min: 0, matching: element.name == "param") {
                representation.params.append(try self.param($0, parent: representation))
            }
            
            // otherElements
            try elements.accept(min: 0) {
                representation.otherElements.append($0)
            }
            
            // Register this element by ID so it can be looked up later
            if let id = representation.id {
                try self.registerElement(id: id, element: representation)
            }
            
            return representation
        }
    }
    
    /*
        WADL Param Element
     */
    private func param(_ element: XMLElement, parent: WADLElement?) throws -> WADLParam {
    
        // If this is a reference, search for the element to find the global instance
        if var href = element.attributes["href"] {
            
            // Trim the first charactor and check that it is a # which means its an intra-document reference
            guard href.remove(at: href.startIndex) == "#" else {
                throw Errors.invalidWADL("Invalid reference \(href), only intra-document references are supported at this point.")
            }
            guard let param = elementsByID[href] as? WADLParam else {
                throw Errors.invalidWADL("Representation with id \(href) not defined.")
            }
            return param
            
        } else {
            
            guard let name = element.attributes["name"] else {
                throw Errors.invalidWADL("Param element missing required \"name\" attribute")
            }
            guard let styleString = element.attributes["style"] else {
                throw Errors.invalidWADL("Param element missing required \"name\" attribute")
            }
            guard let style = WADLParam.Style(rawValue: styleString.lowercased()) else {
                throw Errors.invalidWADL("Param invalid value for \"style\" attribute, must be one of matrix, header, query, template, or plain.")
            }
            
            let required  = element.attributes["required"] == "true"
            let repeating = element.attributes["repeating"] == "true"
            
            let param = WADLParam(name: name,
                                  style: style,
                                  id: element.attributes["id"],
                                  type: element.attributes["type"],
                                  defaultValue: element.attributes["default"],
                                  path: element.attributes["path"],
                                  required: required,
                                  repeating: repeating,
                                  fixed: element.attributes["fixed"],
                                  parent: parent)

            // Collect all the child elements for this element
            let elements = XMLNodeCollection<XMLElement>(nodes: element.children)
            
            try elements.accept(min: 0, matching: element.name == "doc") {
                param.docs.append(try self.doc($0, parent: param))
            }
            
            try elements.accept(min: 0, matching: element.name == "option") {
                param.options.append(try self.option($0, parent: param))
            }
            
            try elements.accept(min: 0, matching: element.name == "link") {
                param.links.append(try self.link($0, parent: param))
            }
            
            // otherElements
            try elements.accept(min: 0) {
                param.otherElements.append($0)
            }
            
            // Register this element by ID so it can be looked up later
            if let id = param.id {
                try self.registerElement(id: id, element: param)
            }
            
            return param
        }
    }
    
    private func option(_ element: XMLElement, parent: WADLElement?) throws -> WADLOption {
        
        guard let value = element.attributes["value"] else {
            throw Errors.invalidWADL("Param element missing required \"value\" attribute")
        }
        
        var queryType: WADLMediaType? = nil
        
        if let queryTypeString = element.attributes["queryType"] {
            queryType = WADLMediaType(rawValue: queryTypeString)
        }
        
        return WADLOption(value: value, mediaType: queryType, parent: parent)
    }
    
    private func link(_ element: XMLElement, parent: WADLElement?) throws -> WADLLink {
        return WADLLink(parent: parent)
    }
    
}

