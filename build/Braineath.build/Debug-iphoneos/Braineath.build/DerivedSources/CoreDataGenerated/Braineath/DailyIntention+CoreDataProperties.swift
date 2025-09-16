//
//  DailyIntention+CoreDataProperties.swift
//  
//
//  Created by Ryan Zemri on 16/09/2025.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias DailyIntentionCoreDataPropertiesSet = NSSet

extension DailyIntention {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyIntention> {
        return NSFetchRequest<DailyIntention>(entityName: "DailyIntention")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var intentionText: String?
    @NSManaged public var category: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var reflection: String?

}

extension DailyIntention : Identifiable {

}
