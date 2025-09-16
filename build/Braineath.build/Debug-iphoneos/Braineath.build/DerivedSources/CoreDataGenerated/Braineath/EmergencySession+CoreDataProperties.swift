//
//  EmergencySession+CoreDataProperties.swift
//  
//
//  Created by Ryan Zemri on 16/09/2025.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias EmergencySessionCoreDataPropertiesSet = NSSet

extension EmergencySession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EmergencySession> {
        return NSFetchRequest<EmergencySession>(entityName: "EmergencySession")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var triggerEmotion: String?
    @NSManaged public var intensityBefore: Int16
    @NSManaged public var techniquesUsed: [String]?
    @NSManaged public var duration: Int32
    @NSManaged public var intensityAfter: Int16
    @NSManaged public var notes: String?

}

extension EmergencySession : Identifiable {

}
