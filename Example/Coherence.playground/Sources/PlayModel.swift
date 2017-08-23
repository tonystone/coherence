import Foundation
import CoreData

public class PlayModel {

    public class func newInstance() -> NSManagedObjectModel {

        let commentEntity = NSEntityDescription()
        commentEntity.name = "Comment"
        commentEntity.managedObjectClassName = "NSManagedObject"

        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .integer64AttributeType
        idAttribute.isOptional = false
        idAttribute.isIndexed = true

        let commentAttribute = NSAttributeDescription()
        commentAttribute.name = "comment"
        commentAttribute.attributeType = .stringAttributeType
        commentAttribute.isOptional = false
        commentAttribute.isIndexed = false

        commentEntity.properties = [idAttribute, commentAttribute]

        let model = NSManagedObjectModel()
        model.entities = [commentEntity]

        return model
    }
}
