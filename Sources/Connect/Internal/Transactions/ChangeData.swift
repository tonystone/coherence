///
///  ChangeData.swift
///  Pods
///
///  Created by Tony Stone on 9/15/17.
///
///
import Swift

typealias ValueContainerType = [AnyHashable: Any]

internal class ChangeData : NSObject, NSSecureCoding  {
    static var supportsSecureCoding: Bool = false

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

    public override var description: String {
        return "\(String(describing: type(of: self))) { attributesAndValues: \(attributesAndValues?.description ?? "nil") }"
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

    public override var description: String {
        return "\(String(describing: type(of: self))) { attributesAndValues: \(attributesAndValues?.description ?? "nil"), updatedAttributes: \(updatedAttributes?.description ?? "nil") }"
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

    public override var description: String {
        return "\(String(describing: type(of: self))) {}"
    }
}
