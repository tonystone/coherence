///
///  MetaLogEntry.swift
///
///  Copyright 2015 Tony Stone
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
///  Created by Tony Stone on 12/10/15.
///
import Foundation
import CoreData

internal typealias TransactionID = String

@objc(MetaLogEntry)
internal class MetaLogEntry: NSManagedObject {

    typealias ValueContainerType = [AnyHashable: Any]

    internal class ChangeData : NSObject, NSCoding  {
        required override init() {}
        required init?(coder aDecoder: NSCoder) {}
        func encode(with aCoder: NSCoder) {}
    }
    /**
        NOTE: the attributes in this class are all public because
        it is considered a structure.  We had to make this a class
        to suite the CoreData requirements.
    */
    internal class InsertData : ChangeData {
        var attributesAndValues: ValueContainerType?

        required init() {
            super.init()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            
            attributesAndValues = aDecoder.decodeObject() as? ValueContainerType
        }
        override func encode(with aCoder: NSCoder) {
            aCoder.encode(attributesAndValues)
            super.encode(with: aCoder)
        }
    }

    internal class UpdateData : ChangeData  {
        var attributesAndValues: ValueContainerType?
        var updatedAttributes:   [String]?

        required init() {
            super.init()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            
            attributesAndValues = aDecoder.decodeObject() as? ValueContainerType
            updatedAttributes   = aDecoder.decodeObject() as? [String]
        }
        
        override func encode(with aCoder: NSCoder) {
            aCoder.encode(attributesAndValues)
            aCoder.encode(updatedAttributes)
            super.encode(with: aCoder)
        }
    }

    internal class DeleteData : ChangeData   {

        required init() {
            super.init()
        }

        required  init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        override func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
        }
    }
}

extension MetaLogEntry.InsertData {

    public override var description: String {
        return "\(String(describing: type(of: self))) { attributesAndValues: \(attributesAndValues?.description ?? "nil") }"
    }
}

extension MetaLogEntry.UpdateData {

    public override var description: String {
        return "\(String(describing: type(of: self))) { attributesAndValues: \(attributesAndValues?.description ?? "nil") updatedAttributes:  \(updatedAttributes?.description ?? "nil") }"
    }
}

extension MetaLogEntry.DeleteData {

    public override var description: String {
        return "\(String(describing: type(of: self))) {}"
    }
}
