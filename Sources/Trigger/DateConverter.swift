
import Foundation

public struct DateConverter {
    
    public static func convert(from Iso8601Date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        guard let dateRepresentation = dateFormatter.date(from:Iso8601Date) else {
            print ("Date object creation was not successful")
            exit(1)
        }
        let currentDate = DateFormatter.localizedString(from: dateRepresentation, dateStyle: .medium, timeStyle: .medium)
        return currentDate
    }
}

