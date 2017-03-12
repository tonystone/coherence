///
///  Configuration.swift
///
///  Copyright 2016 Tony Stone
///
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
///
///  Created by Tony Stone on 6/22/15.
///
import TraceLog

// Default values for override methods
public let defaultBundleKey = "CCConfiguration"
public let defaultDefaults  = [String: AnyObject]()

/**
    Main Configuration implementation
*/
open class Configuration<P: NSObjectProtocol> {
    
    /**
     *  This method should return a dictionary keyed by property name
     *  with the values for defaults in the instance. Value types must
     *  be of the correct type for the property or be able to be converted
     *  to the correct type.
     */
    open class func defaults () -> [String: AnyObject] {
        return defaultDefaults
    }
    
    /**
     *  This method should return the name of the main bundle dictionary
     *  key to search for the configuration option keys.
     *
     * @default CCConfiguration
     */
    open class func bundleKey () -> String {
        return defaultBundleKey
    }
    
    /**
        Creates an implementation and instance of an object for the protocol (P) specified.
     
        - Parameters
            - defaults: A dictionary of property names and default values for those properties.
            - bundleKey: The key used to store the property names and values in the Info.plist file.  The value of the key must be a dictionary.
     
        - Returns: An instance of an Object that implements the protocol specified by P.
     */
    
    public final class func instance(_ defaults: [String: AnyObject]? = nil, bundleKey: String? = nil) -> P {
        
        // Lookup the protocol in the Objective-C runtime to get the Protocol object pointer
        let conformingProtocol: Protocol = abortIfNil(message: "Could not create instance for protoocol \(P.self)") {
           return objc_getProtocol(String(reflecting: P.self))
        }
        
        let defaults  = defaults  ?? self.defaults()
        let bundleKey = bundleKey ?? self.bundleKey()
        
        return createInstance(conformingProtocol, defaults: defaults, bundleKey: bundleKey) as! P
    }
}

@objc
open class CCConfiguration : NSObject {

    /**
        Creates an implementation and instance of an object for the protocol (P) specified.
     
        - Parameters
            - objcProtocol: A configuration Protocol to create an instance for.  A class will be created that implements this protocol.
     
        - Returns: An instance of an Object that implements the protocol specified by objcProtocol.
     */
    @objc
    public final class func configurationForProtocol (_ objcProtocol: Protocol) -> AnyObject? {
        return createInstance(objcProtocol, defaults: defaultDefaults, bundleKey: defaultBundleKey)
    }
    
    /**
        Creates an implementation and instance of an object for the protocol (P) specified.
     
        - Parameters
            - objcProtocol: A configuration Protocol to create an instance for.  A class will be created that implements this protocol.
            - defaults: A dictionary of property names and default values for those properties.
     
        - Returns: An instance of an Object that implements the protocol specified by objcProtocol.
     */
    @objc
    public final class func configurationForProtocol (_ objcProtocol: Protocol, defaults: [String: AnyObject]) -> AnyObject? {
        return createInstance(objcProtocol, defaults: defaults, bundleKey: defaultBundleKey)
    }
    
    /**
        Creates an implementation and instance of an object for the protocol (P) specified.
     
        - Parameters
            - objcProtocol: A configuration Protocol to create an instance for.  A class will be created that implements this protocol.
            - defaults: A dictionary of property names and default values for those properties.
            - bundleKey: The key used to store the property names and values in the Info.plist file.  The value of the key must be a dictionary.
     
        - Returns: An instance of an Object that implements the protocol specified by objcProtocol.
     */
    @objc
    public final class func configurationForProtocol (_ objcProtocol: Protocol, defaults: [String: AnyObject], bundleKey: String) -> AnyObject? {
        return createInstance(objcProtocol, defaults: defaults, bundleKey: bundleKey)
    }
}

/**
 Internal load exstension
 */
internal /* Testable */
enum ConfigurationErrors: Error {
    case failedInitialization(String)
}

private func createInstance(_ conformingProtocol: Protocol, defaults: [String: AnyObject], bundleKey: String) -> AnyObject {

    let config = abortIfNil(message: "Could not create instance for protoocol \(NSStringFromProtocol(conformingProtocol))") {
        return CCObject.instance(for: conformingProtocol, defaults: defaults, bundleKey: bundleKey) as? NSObject
    }

    abortIfError {
        try loadObject(for: conformingProtocol, anObject: config, bundleKey: bundleKey, defaults: defaults)
    }
    return config
}

internal /* Testable */
func loadObject(for conformingProtocol: Protocol, anObject: NSObject, bundleKey: String, defaults: [AnyHashable: Any]) throws {
    
    var errorString = String()
    
    let values = Bundle.main.infoDictionary?[bundleKey] as? [AnyHashable: Any]

    var propertyCount: UInt32 = 0
    let properties = protocol_copyPropertyList(conformingProtocol, &propertyCount)
    
    defer { properties?.deinitialize()
        properties?.deallocate(capacity: 1)
    }

    if values == nil  {
        errorString += "\tBundle key \"\(bundleKey)\" missing from Info.plist file or is an invalid type.  The type must be a dictionary."
    } else {

        for index in 0..<propertyCount {
            let property = properties?[Int(index)]

            if let propertyName = String(validatingUTF8: property_getName(property)) {

                if let value = values?[propertyName] {

                    anObject.setValue(value, forKey: propertyName)

                } else  if let value =  defaults[propertyName] {

                    anObject.setValue(value, forKey: propertyName)
                } else {

                    if errorString.characters.count == 0 {
                        errorString += "\tKey \"\(propertyName)\" missing from Info.plist and no default was supplied, a value is required."
                    }
                }
            }
        }
    }
    
    if errorString.characters.count > 0  {
        throw ConfigurationErrors.failedInitialization("Error(s) loading protocol.\r\(errorString)")
    }
}

