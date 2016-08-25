//
//  ConfigurationReader.swift
//  Pods
//
//  Created by Tony Stone on 8/23/16.
//
//

import Foundation
import TraceLog

internal class ConfigurationReader {
    
    //
    // Read the connect configuration from the file at the URL
    //
    class func configuration(fromURL url: NSURL) throws -> MGWADLApplication {
    
       let xmlDocument = MGXMLReader.xmlDocumentFromURL(url, elementClassPrefixes: ["MGConnectWADL", "MGWADL"])

        // XML document should only have 1 element of type MGWADLApplication
        let applications = xmlDocument.elements().filter { (anObject) -> Bool in
            return anObject is MGWADLApplication
        }
        
        if applications.count == 1 {
            if let wadlApplication = applications[0] as? MGWADLApplication {
                return wadlApplication
            }
        } else {
            logError { "The connect confuration file supplied is invalid, there can only be one application specified." }
        }
        
        return MGWADLApplication()
    }
}