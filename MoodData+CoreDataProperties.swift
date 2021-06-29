//
//  MoodData+CoreDataProperties.swift
//  anom
//
//  Created by 中村隼人 on 2021/06/22.
//
//

import Foundation
import CoreData


extension MoodData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoodData> {
        return NSFetchRequest<MoodData>(entityName: "MoodData")
    }

    @NSManaged public var mood: Int64
    @NSManaged public var dateKey: Date?

}

extension MoodData : Identifiable {

}
