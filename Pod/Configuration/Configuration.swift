/**
 *   CCConfiguration.m
 *
 *   Copyright 2015 The Climate Corporation
 *   Copyright 2015 Tony Stone
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 *   Created by Tony Stone on 6/22/15.
 */
import TraceLog

internal let ErrorDomain      = "FSErrorDomain"
internal let DefaultBundleKey = "TCCConfiguration"

internal enum ErrorDomainCode: Int {
    case InitializationErrorCode     = 100
    case MissingConfigurationKey     = 101
    case InvalidConfigurationKeyType = 102
}

@objc(CCConfiguration)
public class Configuration : NSObject {

    /**
     *  This method should return a dictionary keyed by property name
     *  with the values for defaults in the instance. Value types must
     *  be of the correct type for the property or be able to be converted
     *  to the correct type.
     */
    public class func defaults () -> [String: AnyObject] {
        return [String: AnyObject]()
    }
    
    /**
     *  This method should return the name of the main bundle dictionary
     *  key to search for the configuration option keys.
     *
     * @default TCCConfiguration
     */
    public class func bundleKey () -> String {
        return DefaultBundleKey
    }

    
    /**
     *  Creates an implementation and instance of
     *  configuration instance for the protocol
     *  specified.
     */
    @objc
    @warn_unused_result
    public final class func configurationForProtocol (objcProtocol: Protocol) -> AnyObject? {
        return instance(objcProtocol)
    }
    
    /**
    *  Creates an implementation and instance of
    *  configuration instance for the protocol
    *  specified.
    */
    @nonobjc
    @warn_unused_result
    public final class func instance<P: protocol<>> (objcProtocol: Protocol) -> P? {
        return instance(objcProtocol, defaults: self.defaults())
    }
    
    /**
     *  Creates an implementation and instance of
     *  configuration instance for the protocol
     *  specified.
     */
    @nonobjc
    @warn_unused_result
    public final class func instance<P: protocol<>> (objcProtocol: Protocol, defaults: [String: AnyObject]) -> P? {
        return instance(objcProtocol, defaults: defaults, bundleKey: self.bundleKey())
    }

    /**
     *  Creates an implementation and instance of
     *  configuration instance for the protocol
     *  specified.
     */
    @nonobjc
    @warn_unused_result
    private final class func instance<P: protocol<>> (objcProtocol: Protocol, defaults: [String: AnyObject], bundleKey: String) -> P? {
    
        if let config = CCObject.instanceForProtocol(objcProtocol, defaults: defaults, bundleKey: bundleKey) as? NSObject {
            self.loadObject(config, conformingProtocol: objcProtocol, bundleKey: bundleKey, defaults: defaults)
            
            return config as? P
        }
        return nil
    }

    private class func loadObject(anObject: NSObject, conformingProtocol: Protocol, bundleKey: String, defaults: [NSObject : AnyObject]) {

        var errors = [NSError]()

        if let values = NSBundle.mainBundle().infoDictionary?[bundleKey] as? [NSObject: AnyObject] {  
            self.loadObject(anObject, conformingProtocol: conformingProtocol, values: values, defaults: defaults, errors: &errors)
            
        } else {
            errors.append(NSError(domain: ErrorDomain, code: ErrorDomainCode.MissingConfigurationKey.rawValue, userInfo: [NSLocalizedDescriptionKey: "Required bundle key \(bundleKey) missing form Info.plist file"]))
        }
        
        if errors.count > 0 {
            var reasonMessage = "The Following error(s) occured during initialization of \(conformingProtocol) instance.\n\n"

            for error in errors {
                
                reasonMessage += "\t\(error.localizedDescription) \n"
            }
            
            logError {
                reasonMessage
            }
        }
    }

    private class func loadObject(anObject: NSObject, conformingProtocol: Protocol, values: [NSObject : AnyObject], defaults: [NSObject : AnyObject], inout errors: [NSError]) {

        var propertyCount: UInt32 = 0
        let properties = protocol_copyPropertyList(conformingProtocol, &propertyCount)
        
        defer { properties.destroy()
                properties.dealloc(1)
        }
        
        for index in 0...(propertyCount - 1) {
            let property = properties[Int(index)]
            
            if let propertyName = String.fromCString(property_getName(property)) {
                
                if let value = values[propertyName] ?? defaults[propertyName] {
                    
                    anObject.setValue(value, forKey: propertyName)
                    
                } else {
                    errors.append(NSError(domain: ErrorDomain, code: ErrorDomainCode.MissingConfigurationKey.rawValue, userInfo:
                        [NSLocalizedDescriptionKey: "\(propertyName) key was missing from the info.plist and no default value was supplied, this value is required."]))
                }
            }
        }
    }
}
