//
//  HomeModel.swift
//

import Foundation

struct GetPriceListModel : Codable {
    let success : Bool?
    let status : Int?
    let message : String?
    let data : GetPriceListModelData?

}
struct GetPriceListModelData : Codable {
    let data : [GetPriceList]?
    let total : Int?
    let per_page : Int?
    let current_page : Int?
    let last_page : Int?

}
struct GetPriceList : Codable {
    let id : Int?
    let name : String?
    let description: String?
    let pricing_display_image : String?
    let price : String?
    let price2 : String?
    let is_paid: Bool?
    let android_android_key : String?
    let apple_apple_key : String?
    let stripe_stripe_key : String?
}
