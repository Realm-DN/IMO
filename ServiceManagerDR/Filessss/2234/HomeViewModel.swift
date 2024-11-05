import Combine
import Foundation

class HomeViewModel {
    @Published var priceList: [GetPriceList] = []
    @Published var errorMessage: String?
    @Published var current_page: Int? = 1
    @Published var lastPage: Int? = 1

    func fetchPrice() {
        let param : Parameters = [
            .page : current_page ?? 1
        ]
        let loader = priceList.isEmpty
        Task {
            do {
                let priceData: GetPriceListModel = try await networkService.requestAPI( type: GetPriceListModel.self, apiEndPoint: .get_prices, parameters: param, showIndicator: loader)
                DispatchQueue.main.async {
                    if priceData.success == true{
                        self.lastPage = priceData.data?.last_page
                        if priceData.data?.current_page == 1{
                            self.priceList = priceData.data?.data ?? []
                        }else{
                            self.priceList.append(contentsOf: priceData.data?.data ?? [])
                        }
                    }
                    else{
                        self.errorMessage = priceData.message ?? ErrorMessages.somethingWentWrong
                    }
           
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
