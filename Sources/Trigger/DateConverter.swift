import Foundation

public struct DateConverter {
    
    public static func convert(from iso8601Date: String) -> String {
        let dateFormatter = DateFormatter()
        var currentDate = ""
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let dateObject = dateFormatter.date(from: iso8601Date) {
            dateFormatter.timeZone = TimeZone(abbreviation: "EST")
            dateFormatter.timeStyle = .long
            dateFormatter.dateStyle = .long
            currentDate = dateFormatter.string(from: dateObject)
        } else {
            print ("Date object creation was not successful")
        }
        return currentDate
    }
}
