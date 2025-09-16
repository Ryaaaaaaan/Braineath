//
//  UserPreferences+CoreDataProperties.swift
//  
//
//  Created by Ryan Zemri on 16/09/2025.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias UserPreferencesCoreDataPropertiesSet = NSSet

extension UserPreferences {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserPreferences> {
        return NSFetchRequest<UserPreferences>(entityName: "UserPreferences")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var preferredTheme: String?
    @NSManaged public var notificationsEnabled: Bool
    @NSManaged public var reminderTimes: [Date]?
    @NSManaged public var preferredBreathingPattern: String?
    @NSManaged public var soundEnabled: Bool
    @NSManaged public var hapticEnabled: Bool
    @NSManaged public var privacyLevel: String?

}

extension UserPreferences : Identifiable {

}
