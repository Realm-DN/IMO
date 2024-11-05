//
//  String+Extensions.swift
//

import Foundation
import UIKit

//extension String{
//
//
////    // Example usage:
////    let websiteURL = "https://www.example.com"
////    if isValidURL(urlString: websiteURL) {
////        print("Valid URL")
////    } else {
////        print("Invalid URL")
////    }
//
//}

//func isValidURL(urlString: String) -> Bool {
//    // Regular expression to match URLs
//    let urlRegex = #"((http|https)://)((www\.)?)(([a-zA-Z0-9\-_]+\.[a-zA-Z]{2,})|(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}))(\:\d{1,5})?(/([a-zA-Z0-9\-\._\?\,\'/\\\+&%\$#\=~])*?)?"#
//    
//    let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegex)
//    return urlTest.evaluate(with: urlString)
//}

func isValidURL(_ urlString: String) -> Bool {
    if let url = URL(string: urlString) {
        return UIApplication.shared.canOpenURL(url)
    }
    return false
}
func isValidUrlString(url: String) -> Bool {
    let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
    let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
    let result = urlTest.evaluate(with: url)
    return result
}
//extension String{
//    func isValidURL() -> Bool {
//        // Regular expression to match URLs
//        let urlRegex = #"((http|https)://)((www\.)?)(([a-zA-Z0-9\-_]+\.[a-zA-Z]{2,})|(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}))(\:\d{1,5})?(/([a-zA-Z0-9\-\._\?\,\'/\\\+&%\$#\=~])*?)?"#
//        
//        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegex)
//        return urlTest.evaluate(with: self)
//    }
//}

//func isNonEmptyString(_ str: String?) -> Bool {
//    guard let str = str else {
//        return false // If the string is nil, consider it empty
//    }
//    
//    return !str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//}


extension String {
//     func trimmed() -> String {
//            return self.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
    
    func trimmed() -> String {
        // Remove all whitespace characters (spaces, tabs, newlines)
        return self.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
    }

    
    var capitalizeFirst: String {
        if self.count == 0 {
            return self
        }
        return String(self[self.startIndex]).capitalized + String(self.dropFirst())
    }
    
    
    
    func getUSFormattedTextWithCommas() -> String? {
        guard let number = Double(self) else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: number))
    }
    
    func removeUSNumberFormattingWithRegex() -> String {
        return self.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
    }
    
    func countOfDigitsIgnoringCommasAndNonDigits() -> Int {
        return self.filter { $0.isNumber }.count
    }
}

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
    // Function to convert UTC date string to local date and time
        func toLocalDateTime() -> (date: String, time: String)? {
            let dateFormatter = DateFormatter()
            
            // Set the input format and UTC time zone
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            
            // Set the locale to US
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            // Convert the string to a Date object
            if let utcDate = dateFormatter.date(from: self) {
                // Set the output format for the local date
                dateFormatter.dateFormat = "MM/dd/yyyy"
                dateFormatter.timeZone = TimeZone.current
                
                let localDate = dateFormatter.string(from: utcDate)
                
                // Set the output format for the local time
                dateFormatter.dateFormat = "HH:mm a"
                
                let localTime = dateFormatter.string(from: utcDate)
                
                return (date: localDate, time: localTime)
            }
            
            return nil
        }
}
func isNotEmpty(_ text: String?) -> Bool {
   return !(text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
}


// Function to convert a string array to a JSON string
func jsonString(from stringArray: [String]) -> String? {
    do {
        // Serialize the array into JSON data
        let jsonData = try JSONSerialization.data(withJSONObject: stringArray, options: [])
        
        // Convert JSON data to string
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
    } catch {
        print("Error serializing string array to JSON: \(error)")
    }
    
    return nil
}




