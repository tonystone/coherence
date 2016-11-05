//
//  OpenAPIReader.swift
//  Pods
//
//  Created by Tony Stone on 9/12/16.
//
//

import Swift

///
///
///
/// Mapping:
///
/// OpenAPI         ->  Connect
/// ---------------     -----------------
/// doc                 Configuration
/// doc.info.title      Configuration
/// doc.info.version    Configuration
/// doc.consumes        Configuration.consumes
/// doc.produces        Configuration.produces
///
/// doc.schemes         ServiceDescription
/// doc.host            ServiceDescription
/// doc.basePath        ServiceDescription
/// doc.paths           ServiceDescription
///
/// path                ResourceDescription
///
///
final class OpenAPIReader : ConfigurationReader {
    
    ///
    /// Errors thrown by this classes methods
    ///
    enum Errors : Error {
        case InvalidSpecification(String)
    }
    
    ///
    /// Primary method for parsing OpenAPI spec streams
    ///
    static func read(stream: InputStream, sourceURL: URL? = nil) throws -> Configuration {
        
        let reader = self.init()
        
        return try reader.parse(stream: stream, sourceURL: sourceURL)
    }
    
    ///
    /// Internal constructor
    ///
    private init() {}
    
    private var host: String? = nil
    private var base: String? = nil
    private var consumes: [MediaType] = [MediaType.applicationJSON]
    private var produces: [MediaType] = [MediaType.applicationJSON]
    
    ///
    /// reference stores a dictionary of dictionaries that contains the OpenAPI json objects.
    ///
    /// Example:
    ///
    /// ["parameters" : [
    ///                   "regionId" : [
    ///                                 "name": "regionId",
    ///                                 "in": "path",
    ///                                 "description": "regionID to fetch",
    ///                                 "required": true,
    ///                                 "type": "integer"
    ///                                ]
    ///                 ],
    ///  "definitions": [
    ///                   "Country" : [
    ///                                 "type": "object",
    ///                                 "properties": [
    ///                                                 "id": [
    ///                                                        "type": "integer"
    ///                                                       ],
    ///                                                 "name": [
    ///                                                         "type": "string"
    ///                                                         ]
    ///                                                ],
    ///                                 "required": [ "id", "name" ]
    ///                               ]
    ///                 ]
    /// ]
    ///
    private var references: [String : [String : [String : Any]]] = [:]

    ///
    /// Parse the OpenAPI spec input stream.
    ///
    private func parse(stream: InputStream, sourceURL: URL? = nil) throws -> Configuration {

        let json = try JSONSerialization.jsonObject(with: stream, options: [])
        
        /// Required attributes
        guard  let spec = json  as? [AnyHashable: Any] else {
            throw Errors.InvalidSpecification("The input stream has an invalid format and can not be parsed.")
        }
        guard let openAPIVersion = spec["swagger"] as? String else {
            throw Errors.InvalidSpecification("Specification missing 'swagger' attribute.")
        }
        guard ["2.0"].contains(openAPIVersion) else {
            throw Errors.InvalidSpecification("Unsupported swagger version, only 2.0 specification currently supported.")
        }

        guard let info = spec["info"] as? [String : Any] else {
            throw Errors.InvalidSpecification("Specification missing 'info' attribute.")
        }
        guard let title = info["title"] as? String else {
            throw Errors.InvalidSpecification("Specification missing 'info.title' attribute.")
        }
        guard let version = info["version"] as? String else {
            throw Errors.InvalidSpecification("Specification missing 'info.version' attribute.")
        }
        guard let paths = spec["paths"] as? [String : [String : Any]] else {
            throw Errors.InvalidSpecification("Specification missing 'paths' attribute.")
        }
    
//        let requiredComponents = version.characters.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false).map{ String($0) }.flatMap{ Int($0) }.filter{ $0 >= 0 }
//        
//        let major = requiredComponents[0]
//        let minor = requiredComponents[1]
//        let patch = requiredComponents[2]
        
        /// Optionals attributes
        if let values = spec["consumes"] as? [String] {
            self.consumes.removeAll()
            
            for string in values {
                self.consumes.append(MediaType(rawValue: string))
            }
        }
        
        if let values = spec["produces"] as? [String] {
            self.produces.removeAll()
            
            for string in values {
                self.produces.append(MediaType(rawValue: string))
            }
        }
        
        var schemes: [Scheme] = []
        
        if let schemeStrings = spec["schemes"] as? [String] {
            for schemeString in schemeStrings {
                if let scheme = Scheme(rawValue: schemeString) {
                    schemes.append(scheme)
                }
            }
        } else if let schemeString = sourceURL?.scheme ,
            let scheme = Scheme(rawValue: schemeString) {
            
            schemes.append(scheme)
        }
    
        /// Must have a scheme or be able to calaculate one from the sourceURL
        guard schemes.count > 0 else {
            throw Errors.InvalidSpecification("Specification missing 'scheme' attribute.")
        }
        
        var host: String? = nil
        
        if let hostName = spec["host"] as? String {
            host = hostName
            
        } else if let hostName = sourceURL?.host {
            host = hostName
        }
        /// Must have a scheme or be able to calaculate one from the sourceURL
        guard host != nil else {
            throw Errors.InvalidSpecification("Specification missing 'host' attribute.")
        }
        
        //
        // Now that we know we have all the required items, process the reference items first so they can be found later when looked up
        //
        
        // First the parameters
        if let paramaters = spec["parameters"] as? [String : [String : Any]] {
            for (name, value) in paramaters {
                try self.addReference(object: value, key: name, at: "parameters")
            }
        }
        // Now the definitions
        if let definitions = spec["definitions"] as? [String : [String : Any]] {
            for (name, value) in definitions {
                /// Note a definition objects are JSON schema objects so we call self.schema
                try self.addReference(object: value, key: name, at: "definitions")
            }
        }
        
        var resources: [ResourceDescription] = []
        
        for (path, value) in paths {
            resources.append(try self.resource(path: path, value: value))
        }
        let basePath = spec["basePath"] as? String

        let service = ServiceDescription(schemes: schemes, host: host!, basePath: basePath, resources: resources)

        return Configuration(name: title, version: version, services: [service])
    }
    
    ///
    /// Parse an path element from the OpenAPI spec.
    ///
    private func resource(path: String, value: [String : Any]) throws -> ResourceDescription {
        
        var pathParameters = try path.pathTemplateParameters()
        
        var parameters: [ParameterDescription] = []
        
        if let values = value["parameters"] as? [[String : Any]] {
            for value in values {
                let parameter = try self.parameter(value: value)
                
                guard let parameterIndex = pathParameters.index(of: parameter.name) else {
                    throw Errors.InvalidSpecification("Parameter '\(parameter.name)' is missing from path template '\(path)'.")
                }
                
                /// Remove this path parameter from the list
                pathParameters.remove(at: parameterIndex)
                
                parameters.append(parameter)
            }
        }
        
        /// You must have a parameter defined for each template item
        guard pathParameters.count == 0 else {
            throw Errors.InvalidSpecification("The following template items do not have parameters defined for them '\(pathParameters)'")
        }
        
        var operations: [OperationDescription] = []
        
        if let operation = value["get"] as? [String : Any] {
            operations.append(try self.operation(type: "get", value: operation))
        }
        if let operation = value["put"] as? [String : Any] {
            operations.append(try self.operation(type: "put", value: operation))
        }
        if let operation = value["post"] as? [String : Any] {
            operations.append(try self.operation(type: "post", value: operation))
        }
        if let operation = value["delete"] as? [String : Any] {
            operations.append(try self.operation(type: "delete", value: operation))
        }
        if let operation = value["options"] as? [String : Any] {
            operations.append(try self.operation(type: "options", value: operation))
        }
        if let operation = value["head"] as? [String : Any] {
            operations.append(try self.operation(type: "head", value: operation))
        }
        if let operation = value["patch"] as? [String : Any] {
            operations.append(try self.operation(type: "patch", value: operation))
        }
        
        return ResourceDescription(path: path, parameters: parameters, operations: operations)
    }
    
    ///
    /// Parse an parameter element from the OpenAPI spec.
    ///
    private func parameter(value: [String : Any]) throws -> ParameterDescription {
        
        // If this is a reference param, simply look it up
        if let ref = value["$ref"] as? String {
            return try parameter(value: try self.resolveReference(reference: ref))
        }
        //
        // It's not a reference parameter
        //
        
        // Required attributes
        guard let name = value["name"] as? String else {
            throw Errors.InvalidSpecification("Parameter missing 'name' attribute.")
        }
        guard let locationString = value["in"] as? String else {
            throw Errors.InvalidSpecification("Parameter missing required 'in' attribute")
        }
        guard let location = ParameterLocation(rawValue: locationString.lowercased()) else {
            throw Errors.InvalidSpecification("Parameter invalid value for 'in' attribute. Possible values are 'query', 'header', 'path', 'formData' or 'body'.")
        }
        
        // Conditionally required attributes
        var required: Bool = false
        
        if location == .path {
            
            guard let requiredValue = value["required"] as? Bool  else {
                throw Errors.InvalidSpecification("Parameter missing required 'required' attribute")
            }
            required = requiredValue
            
        } else if let requiredValue = value["required"] as? Bool {
            required = requiredValue
        }
        
        return ParameterDescription(name: name, location: location, type: try schemaPrimitiveType(value: value, required: required))
    }
    
    private func schemaPrimitiveType(value: [String : Any], required: Bool) throws -> SchemaPrimitiveType {
        
        if let typeString = value["type"] as? String {
            switch typeString {
                case "string":  return try schemaString(value: value, required: required)
                case "number":  return try schemaNumber(value: value, required: required)
                case "integer": return try schemaInteger(value: value, required: required)
                case "boolean": return try schemaBoolean(value: value, required: required)
            default: break
            }
        }
        throw Errors.InvalidSpecification("Parameter missing required 'type' attribute")
    }
    
    ///
    /// Parse an operation element from the OpenAPI spec.
    ///
    private func operation(type: String, value: [String : Any]) throws -> OperationDescription {
        
        /// Requried attributes
        let responses: [String : ResponseDescription] = [:]
        
        guard let responseObjects = value["responses"] as? [String : [String : Any]]  else {
            throw Errors.InvalidSpecification("Operation missing required 'responses' attribute")
        }
        
        for (_, _) in responseObjects {
//            responses.append(try self.response(name: name, value: value))
        }
        
        /// Optional attributes
        var consumes: [MediaType] = self.consumes
        var produces: [MediaType] = self.produces
        
        if let values = value["consumes"] as? [String] {
            consumes.removeAll()
            
            for string in values {
                consumes.append(MediaType(rawValue: string))
            }
        }
        
        if let values = value["produces"] as? [String] {
            produces.removeAll()
            
            for string in values {
                produces.append(MediaType(rawValue: string))
            }
        }
        
        let parameters: [ParameterDescription] = []
        
        if let values = value["parameters"] as? [[String : Any]] {
            for _ in values {
//                parameters.append(try self.parameter(value: value))
            }
        }
        
        return OperationDescription(type: type, consumes: consumes, produces: produces, parameters: parameters, responses: responses)
    }
    
    ///
    /// Parse an response element from the OpenAPI spec.
    ///
    private func response(name: String, value: [String : Any]) throws -> ResponseDescription {
        
        let headers: [String : String] = [:]
        
//        if let values = value["headers"] as? [[String : Any]] {
//            for value in values {
//                headers.append()
//            }
//        }
        
        var schema: SchemaType? = nil
        
        if let values = value["schema"] as? [String : Any] {
            schema = try self.schema(value: values)
        }
        
        return ResponseDescription(code: name, headers: headers, content: [MediaType.applicationJSON : schema!])
    }
    
    
    ///
    /// Parse an definition element from the OpenAPI spec.
    ///
    private func schema(value: [String : Any], required: Bool = true) throws -> SchemaType {
        
        // If this is a reference param, simply look it up
        if let ref = value["$ref"] as? String {
            return try schema(value: try self.resolveReference(reference: ref), required: required)
        }
        //
        // It's not a reference definition
        //

        /// Required attributes
        
        guard let type = value["type"] as? String else {
            throw Errors.InvalidSpecification("Schema missing required 'type' attribute")
        }
        
        switch type {
        case "object":
            return try self.schemaObject(value: value, required: required)
        case "array":
            return try self.schemaArray(value: value, required: required)
        case "string":
            return try self.schemaString(value: value, required: required)
        case "integer":
            return try self.schemaInteger(value: value, required: required)
        case "number":
            return try self.schemaNumber(value: value, required: required)
        case "boolean":
            return try self.schemaBoolean(value: value, required: required)
        case "null":
            return try self.schemaNull(value: value, required: required)
        default:
            break
        }
        
        throw Errors.InvalidSpecification("Unknown schema instance type '\(type)'")
    }
    
    private func schemaObject(value: [String : Any], required: Bool = true) throws -> SchemaObject {
        
        // Conditionally required attributes
        var requiredProperties: [String] = []
        
        if let required = value["required"] as? [String] {
            requiredProperties = required
        }
        
        var properties: [String : SchemaType] = [:]
        
        if let values = value["properties"] as? [String : [String : Any]] {
            for (name, value) in values {
                properties[name] = try self.schema(value: value, required: requiredProperties.contains(name))
            }
        }
        return SchemaObject(properties: properties)
    }

    private func schemaArray(value: [String : Any], required: Bool = false) throws -> SchemaArray {
        
        // Required attributes
        guard let element = value["items"] as? [String : Any] else {
            throw Errors.InvalidSpecification("Array missing required 'items' attribute")
        }
        return SchemaArray(element: try self.schema(value: element, required: required))
    }
    
    ///
    /// Parse an String element from the OpenAPI spec.
    ///
    private func schemaString(value: [String : Any], required: Bool = true) throws -> SchemaString {
        
        return SchemaString(required: required)
    }
    
    ///
    /// Parse an Integer element from the OpenAPI spec.
    ///
    private func schemaInteger(value: [String : Any], required: Bool = true) throws -> SchemaInteger {
        
        return SchemaInteger(required: required)
    }
    
    ///
    /// Parse an Number element from the OpenAPI spec.
    ///
    private func schemaNumber(value: [String : Any], required: Bool = true) throws -> SchemaNumber {

        return SchemaNumber(required: required)
    }
    
    ///
    /// Parse an Boolean element from the OpenAPI spec.
    ///
    private func schemaBoolean(value: [String : Any], required: Bool = true) throws -> SchemaBoolean {
        return SchemaBoolean(required: required)
    }

    ///
    /// Parse an null element from the OpenAPI spec.
    ///
    private func schemaNull(value: [String : Any], required: Bool = true) throws -> SchemaNull {
        return SchemaNull(required: required)
    }
    
    ///
    /// Store a reference object in the index
    ///
    private func addReference(object: [String : Any], key: String, at path: String) throws {
        
        if var _ = references[path] {
            references[path]?[key] = object
        } else {
            references[path] = [key : object]
        }
    }
    
    ///
    /// Resolve a reference link either externally or internally
    ///
    private func resolveReference(reference: String) throws -> [String : Any] {
        
        let components = reference.components(separatedBy: "/")
        
        if let first = components.first {
            
            if first == "#" {
                if components.count == 3, let target = components.last, target != first  {
                    
                    let path = components[1]
                    ///
                    /// Locate the path for the object and the object itself,
                    /// if found, return it
                    ///
                    if let object = references[path]?[target]  {
                        return object
                    }
                    throw Errors.InvalidSpecification("Reference object not found for reference '\(reference)'")
                }
            } else if first.hasSuffix(".json") {
                // Parse the file and locate the element
            }
        }
        throw Errors.InvalidSpecification("Invalid reference '\(reference)'.")
    }
}

private extension String {
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
    
    func pathTemplateParameters() throws -> [String] {
        let regex = try NSRegularExpression(pattern: "(?<=\\{)[^\\}]+(?=\\})", options: [])
        
        var parameters: [String] = []
        
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
    
        for match in matches {
            if let range = self.range(from: match.range) {
                parameters.append(self.substring(with: range))
            }
        }
        return parameters
    }

}

