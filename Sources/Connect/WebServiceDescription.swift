//
// Created by Tony Stone on 8/21/16.
//

import Foundation

public let timeoutDefault = 60.0
public let cookieDefault = true

/**
    Main protocol to define an entityAction
 */
public
protocol WebServiceDescription {

    // Required

    /*
     The base address for the webService
     
     Example:
     
     https://my.rightscale.com/api
     
     */
    var address: URLComponents { get }

    /**
     
     The {actionLocations} property MAY cite local names of elements from the instance data of the message to be
     serialized in request IRI by enclosing the element name within curly braces (e.g. "temperature/{town}"):
     
     When constructing the request IRI, each pair of curly braces (and enclosed element name) is replaced by the possibly 
     empty single value of the corresponding element. If a local name appears more than once, the elements are used in the 
     order they appear in the instance data. It is an error for this element to carry an xs:nil attribute whose value is "true".
     
     A double curly brace (i.e. "{{" or "}}") MAY be used to include a single, literal curly brace in the request IRI.
     
     Strings enclosed within single curly braces MUST be element names from the instance data of the input message; local names within 
     single curly braces not corresponding to an element in the instance data are a fatal error.†
     
     Example 1:
     
     RESTful urls
     
        /clouds/{cloudID}/instances/{instanceID}
     
     Paramatized URLs
     
        /instances?id={instanceID}&cloud_id={cloudID}
     
     */
    // TODO: Create a location object that parses the above syntax on init(string: String) and validates the parameters syntax
    var actionLocations: [String : AnyObject] { get }


    // Optional items

    var authenticationScheme: String { get }  //FIXME: MGConnectConfigurationAuthentication? { get }
    var authenticationRealm:  String? { get } // TODO: Change to a specific enum or string

    /**
     
     */
    func parametersForAction(_ action: String) -> [String : AnyObject]

    /*
     */
    func argumentsForAction(_ action: String) -> [String : AnyObject]

    /**
     The amount of time (in seconds) that your WebService should wait for a result from the server.
     
     Default is 30 seconds.
     */
    var timeout: Double { get }

    /**
     Optional define header fields and values to be passed to the web service on each call.
     */
    var headers: [String : String] { get }

    /**
     Should we handle cookies for this actions webserivces
     */
    var cookies: Bool { get }

    /**
     Valid Values are;
     
        "application/x-www-form-urlencoded"
        "application/json"
        "application/xml"

     */
    var inputSerialization: String { get } // TODO: hange to specific enum

    /**
     Valid Values are;
     
        "application/xml"
        "application/json"
     
     Please use the constents below to set the values.

        MGWSDLHTTPExtensionValueSerializationJSON
        MGWSDLHTTPExtensionValueSerializationXML
     */
    var outputSerialization: String { get } // TODO: Change to specific enum

}


/**
 Main protocol to define an entityAction
 */
extension WebServiceDescription {
    
    // Optional items
    
    var authenticationScheme: String? { // FIXME: MGConnectConfigurationAuthentication? {
        get { return nil }
    }
    
    var authenticationRealm:  String? {
        get { return nil }
    }
    
    func parametersForAction(_ action: String) -> [String : AnyObject] {
        return [String : AnyObject]()
    }
    
    func argumentsForAction(_ action: String) -> [String : AnyObject] {
        return [String : AnyObject]()
    }
    
    var timeout: Double {
        get { return timeoutDefault }
    }
    
    var headers: [String : String] {
        get { return [String : String]() }
    }
    
    var cookies: Bool {
        get { return cookieDefault }
    }
    
    var inputSerialization: String {
        get { return "application/x-www-form-urlencoded" }
    }
    

    var outputSerialization: String {
        get { return "application/json" }
    }
    
}
