//
//  SettingModel.swift
//

import Foundation
import UIKit


class CommonSetting{
    
    static let share = CommonSetting()
    
    func getAppSettings(completion:@escaping GeneralCompletion){
        serviceManager.requestAPI(apiEndPoint: .appSettings,showIndicator: false) { (result:Result<AppSettings,Error>) in
            switch result{
            case .success(let response):
                print(response)
                guard let data = response.data else {return}
                userSingleton.saveAppSettingsData(data)
                completion(true, response.message ?? String(with: .somethingWentWrong))
            case .failure(let error):
                print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
}

// Helper function for saving image to temporary file
func saveImageToTemporaryFile(image: UIImage) -> URL? {
    // Implementation for saving image to temporary file
    let directory = FileManager.default.temporaryDirectory
    let fileName = UUID().uuidString + ".jpg"
    let fileURL = directory.appendingPathComponent(fileName)
    if let data = image.jpegData(compressionQuality: 1.0) {
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image to temporary file: \(error)")
            return nil
        }
    }
    return nil
}

func uploadImageS3(fetchedData: FileModelDR, completion: @escaping ([String]) -> Void) {
    serviceManager.requestAPI(apiEndPoint: .s3Upload, mimeType: .files(fetchedData)) { (result: Result<BaseModelS3, Error>) in
        switch result {
        case .success(let response):
            let urlString = response.data?.first ?? ""
            completion(response.data ?? [])
            if response.success == false {
                showToast(message: response.message ?? String(with: .somethingWentWrong))
            }
        case .failure(let error):
            completion([])
            debugPrint("s3 Response failure", error)
        }
    }
}
struct BaseModelS3: Codable {
    let success: Bool?
    let message: String?
    let status: Int?
    let data : [String]?
}

struct User: Codable {
    let id : Int?
    let user_id: Int?
    let fullName: String?
    let image: String?
    let is_admin : Int?
    var amount : String?
    let status : Int?
    let event_id : Int?
    let is_paid : Bool?
    let email : String?
    let userName : String?
    let phone : String?
    enum CodingKeys: String, CodingKey {
        case user_id,id
        case fullName = "full_name"
        case image,is_admin,amount,event_id,is_paid,status
        case email = "email"
        case userName = "user_name"
        case phone
    }
}
