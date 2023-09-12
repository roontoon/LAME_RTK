//
//  GPSDataPoint+CoreDataProperties.swift
//  LAME_RTK
//
//  Created by Roontoon on 9/12/23.
//
//

import Foundation
import CoreData


extension GPSDataPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GPSDataPoint> {
        return NSFetchRequest<GPSDataPoint>(entityName: "GPSDataPoint")
    }

    @NSManaged public var altitude: Double
    @NSManaged public var barometricPressure: Double
    @NSManaged public var course: Double
    @NSManaged public var distanceTraveled: Double
    @NSManaged public var entryType: String?
    @NSManaged public var estimatedTimeOfArrival: Date?
    @NSManaged public var heading: Double
    @NSManaged public var horizontalAccuracy: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var mapID: String?
    @NSManaged public var mowingPattern: String?
    @NSManaged public var proximityToSpecificLocation: Double
    @NSManaged public var speed: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var verticalAccuracy: Double

}

extension GPSDataPoint : Identifiable {

}
