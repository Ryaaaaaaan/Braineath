//
//  MoodEntry+CoreDataProperties.swift
//  
//
//  Created by Ryan Zemri on 16/09/2025.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias MoodEntryCoreDataPropertiesSet = NSSet

extension MoodEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoodEntry> {
        return NSFetchRequest<MoodEntry>(entityName: "MoodEntry")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var primaryEmotion: String?
    @NSManaged public var emotionIntensity: Int16
    @NSManaged public var notes: String?
    @NSManaged public var triggers: [String]?
    @NSManaged public var energyLevel: Int16
    @NSManaged public var stressLevel: Int16
    @NSManaged public var sleepQuality: Int16
    @NSManaged public var weatherImpact: String?
    @NSManaged public var breathingSession: BreathingSession?

}

extension MoodEntry : Identifiable {

}
