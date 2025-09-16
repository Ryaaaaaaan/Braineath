//
//  ThoughtRecord+CoreDataProperties.swift
//  
//
//  Created by Ryan Zemri on 16/09/2025.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias ThoughtRecordCoreDataPropertiesSet = NSSet

extension ThoughtRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ThoughtRecord> {
        return NSFetchRequest<ThoughtRecord>(entityName: "ThoughtRecord")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var situation: String?
    @NSManaged public var automaticThought: String?
    @NSManaged public var emotionBefore: String?
    @NSManaged public var intensityBefore: Int16
    @NSManaged public var cognitiveDistortions: [String]?
    @NSManaged public var balancedThought: String?
    @NSManaged public var emotionAfter: String?
    @NSManaged public var intensityAfter: Int16
    @NSManaged public var actionPlan: String?

}

extension ThoughtRecord : Identifiable {

}
