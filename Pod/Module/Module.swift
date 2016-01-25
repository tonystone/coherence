/**
 *   Module.swift
 *
 *   Copyright 2016 Tony Stone
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
 *   Created by Tony Stone on 1/18/2016.
 */
import Foundation

/**
    CCModule protocol
 
    - Note: This is a backwards compatibility protocol for use only to
            replace exisitng usage of CCModule in Objective-C.
*/
@objc
public protocol CCModule {

    /**
        - Returns the instance of this singleton
    */
    static func instance () -> CCModule!

    /**
        Start the module and services
    */
    func start ()

    /**
        Stop the module and services
    */
    func stop ()

    /**
        Get a service for the protocol passed in.
     
        - Note: These are only protocols that are defined by the module that implements this protocol.
    */
    func serviceForProtocol(aProtocol: Protocol) -> AnyObject!

    /**
        Returns the root view controller for this module
    */
    @available(*,deprecated=0.4.1)
    func rootViewController () -> UIViewController!
    
}