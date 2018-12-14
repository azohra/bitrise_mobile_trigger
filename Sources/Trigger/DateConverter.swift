import Foundation

public struct DateConverter {
    
    public static func convert(from iso8601Date: String) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let dateObject = dateFormatter.date(from: iso8601Date) else {
            print ("Date object creation was not successful")
            exit(1)
        }
        let dateFormatter2 = DateFormatter()
        dateFormatter2.timeZone = TimeZone(abbreviation: "EST")
        dateFormatter2.timeStyle = .long
        dateFormatter2.dateStyle = .long
        let currentDate = dateFormatter2.string(from: dateObject)
        return currentDate
    }
}
