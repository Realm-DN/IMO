//
//  SubscriptionModel.swift
//

import Foundation


struct SubscriptionModel : Codable {
    var data : SubscriptionModelData?
    var message : String?
    var success : Bool?
    var status : Int?
    
}

struct SubscriptionModelData : Codable {
    var plan_status : Bool?
    var plan_name : String?
    var days_left : Int?
    var payment_from : String?
    var subscription_token : String?
    var hrs_left : Int?
    var minute_left : Int?
    var expiry_date : String?
    var expiry_date_without_time : String?
    var is_trial_period : Bool?
    var subscription_type : String?
    var modifiedCreatedDate: String {
            return formatDateStringShowSubs(expiry_date ?? "") ?? "" //formatDateStringComment(created_at ?? "") ?? ""
        }
    
    enum CodingKeys:String,CodingKey{
        case plan_status = "status"
        case plan_name = "subscription_type"
        case is_trial_period = "is_trial_period"
        case days_left = "days_left"
        case payment_from = "payment_method"
        case subscription_token = "receipt_token"
        case hrs_left = "hours_left"
        case minute_left = "minutes_left"
        case expiry_date = "expiry_date"
        case expiry_date_without_time
    }
}

func formatDateStringShowSubs(_ dateString: String) -> String? {

    let inputDateFormat = "yyyy-MM-dd HH:mm:ss"
    let outputDateFormat = "MM/dd/yyyy"
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = inputDateFormat
    
    if let date = dateFormatter.date(from: dateString) {
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = outputDateFormat
        let formattedDate = outputDateFormatter.string(from: date)
        return formattedDate
    } else {
        return nil
    }
}

