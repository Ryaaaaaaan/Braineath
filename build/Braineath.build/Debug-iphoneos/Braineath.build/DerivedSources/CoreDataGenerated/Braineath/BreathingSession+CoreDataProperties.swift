//
//  BreathingSession+CoreDataProperties.swift
//  
//
//  Created by Ryan Zemri on 16/09/2025.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias BreathingSessionCoreDataPropertiesSet = NSSet

extension BreathingSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BreathingSession> {
        return NSFetchRequest<BreathingSession>(entityName: "BreathingSession")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var duration: Int32
    @NSManaged public var breathingPattern: String?
    @NSManaged public var completionPercentage: Double
    @NSManaged public var moodBefore: Int16
    @NSManaged public var moodAfter: Int16
    @NSManaged public var notes: String?
    @NSManaged public var moodEntry: MoodEntry?

}

extension BreathingSession : Identifiable {

}
