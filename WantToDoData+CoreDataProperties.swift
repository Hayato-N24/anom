//
//  WantToDoData+CoreDataProperties.swift
//  anom
//
//  Created by 中村隼人 on 2021/06/29.
//
//

import Foundation
import CoreData


extension WantToDoData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WantToDoData> {
        return NSFetchRequest<WantToDoData>(entityName: "WantToDoData")
    }

    @NSManaged public var checked: Bool
    @NSManaged public var date: String?
    @NSManaged public var wantToDo: String?

}

extension WantToDoData : Identifiable {

}
