//
//  SubscriptionViewModel.swift
//

import Foundation

class SubscriptionViewModel{
    var model : SubscriptionModel?
    var isLoading : Bool? = false
    
    func callWebhookApi(param:[String:Any],completion:@escaping GeneralCompletion){
        serviceManager.requestAPI(apiEndPoint: .urlUpdateSubscription,parameters: param) { (result:Result<SubscriptionModel,Error>) in
            switch result{
            case .success(let response):
                self.model = response
                completion(true, response.message ?? String(with: .somethingWentWrong))
            case .failure(let error):
                print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    func getSubscriptionDetailsApi(completion:@escaping GeneralCompletion){
        serviceManager.requestAPI(apiEndPoint: .urlGetSubscriptionDetails) { (result:Result<SubscriptionModel,Error>) in
            switch result{
            case .success(let response):
                self.model = response
                completion(true, response.message ?? String(with: .somethingWentWrong))
            case .failure(let error):
                print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
}
