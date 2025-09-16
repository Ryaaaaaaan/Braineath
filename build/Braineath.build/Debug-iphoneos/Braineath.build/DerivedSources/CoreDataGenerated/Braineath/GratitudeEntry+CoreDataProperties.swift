//
//  GratitudeEntry+CoreDataProperties.swift
//  
//
//  Created by Ryan Zemri on 16/09/2025.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias GratitudeEntryCoreDataPropertiesSet = NSSet

extension GratitudeEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GratitudeEntry> {
        return NSFetchRequest<GratitudeEntry>(entityName: "GratitudeEntry")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var gratitudeText: String?
    @NSManaged public var category: String?
    @NSManaged public var emotionGenerated: String?
    @NSManaged public var isPrivate: Bool

}

extension GratitudeEntry : Identifiable {

}
