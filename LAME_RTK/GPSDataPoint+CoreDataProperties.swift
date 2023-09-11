import Foundation
import CoreData

extension GPSDataPoint {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GPSDataPoint> {
        return NSFetchRequest<GPSDataPoint>(entityName: "GPSDataPoint")
    }
    // Note: I've removed the @NSManaged properties to avoid redeclaration.
}
