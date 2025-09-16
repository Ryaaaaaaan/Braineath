//
//  Achievement+CoreDataProperties.swift
//  
//
//  Created by Ryan Zemri on 16/09/2025.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias AchievementCoreDataPropertiesSet = NSSet

extension Achievement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Achievement> {
        return NSFetchRequest<Achievement>(entityName: "Achievement")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var achievementType: String?
    @NSManaged public var title: String?
    @NSManaged public var achievementDescription: String?
    @NSManaged public var dateEarned: Date?
    @NSManaged public var isUnlocked: Bool
    @NSManaged public var progress: Int32
    @NSManaged public var requiredProgress: Int32

}

extension Achievement : Identifiable {

}
