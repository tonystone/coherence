/**
 *   MetaLogEntry.swift
 *
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
 *   Created by Tony Stone on 12/10/15.
 */
import Foundation
import CoreData

internal typealias TransactionID = String

@objc internal enum MetaLogEntryType: Int32 {
    case BeginMarker = 1
    case EndMarker   = 2
    case Insert      = 3
    case Update      = 4
    case Delete      = 5
}

@objc(MetaLogEntry) internal class MetaLogEntry: NSManagedObject {

    class LogEntryUpdateData : NSObject, NSCoding  {
        required convenience init?(coder aDecoder: NSCoder) {
            self.init()
        }
        func encodeWithCoder(aCoder: NSCoder) {
        }
    }
    /**
        NOTE: the attributes in this class are all public because
        it is considered a structure.  We had to make this a class
        to suite the CoreData requirements.
    */
    class MetaLogEntryInsertData : LogEntryUpdateData {
        var attributesAndValues: [String : AnyObject]?

        required convenience init?(coder aDecoder: NSCoder) {
            self.init()
            
            attributesAndValues = aDecoder.decodeObject() as? [String : AnyObject]
        }
        override func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(attributesAndValues)
        }

    }

    class MetaLogEntryUpdateData : LogEntryUpdateData  {
        var attributesAndValues: [String : AnyObject]?
        var updatedAttributes:   [String]?

        required convenience init?(coder aDecoder: NSCoder) {
            self.init()
            
            attributesAndValues = aDecoder.decodeObject() as? [String : AnyObject]
            updatedAttributes   = aDecoder.decodeObject() as? [String]
        }
        
        override func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(attributesAndValues)
            aCoder.encodeObject(updatedAttributes)
        }

    }

    class MetaLogEntryDeleteData : LogEntryUpdateData   {
        required convenience init?(coder aDecoder: NSCoder) {
            self.init()
        }
        override func encodeWithCoder(aCoder: NSCoder) {}
    }

}
