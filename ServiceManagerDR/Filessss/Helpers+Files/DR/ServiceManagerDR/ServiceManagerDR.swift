//
//  ServiceManagerDRHelper.swift
//

import UIKit

class ServiceManagerDR: NSObject {
    static let shared = ServiceManagerDR()
    
    private var primaryURL = ""
    private var primaryMethod: HTTPMethod = .get
    private var primaryHeaders: HTTPHeaders?
    private var primaryParams: Parameters?
    
    // MARK: - Public Methods
    
    func requestAPI<T: Decodable>(type: T.Type = T.self, apiEndPoint: APIEndpoint, parameters: Parameters? = nil, mimeType: UploadTypeDR = .fetchData, showIndicator: Bool = true) async throws -> T {
        if showIndicator { startIndicator() }
        defer { if showIndicator { stopIndicator() } }
        
        guard !isConnectedToInternet else {
            showToast(message: ErrorMessages.internetMessage)
            throw NetworkError.noInternetConnection
        }
        
        prepareRequest(apiEndPoint, parameters)
        
        switch mimeType {
        case .fetchData:
            return try await fetchData()
        case .files(let data):
            return try await uploadFiles(fileData: data)
        }
    }
    
    // MARK: - Private Methods
    private func prepareRequest(_ apiEndPoint: APIEndpoint, _ parameters: Parameters?) {
        primaryParams = parameters
        primaryURL = kbaseURL + apiEndPoint.path
        primaryMethod = apiEndPoint.method
        if primaryMethod == .get { primaryParams = nil }
        primaryHeaders = generateHeadersDR()
    }
    
    private func createRequest() -> URLRequest? {
        guard let url = URL(string: primaryURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = primaryMethod.rawValue
        
        primaryHeaders?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key.rawValue)
        }
        
        if primaryMethod != .get, let params = primaryParams {
            let stringKeyedParams = Dictionary(uniqueKeysWithValues: params.map { ($0.key.rawValue, $0.value) })
            request.httpBody = try? JSONSerialization.data(withJSONObject: stringKeyedParams, options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        request.timeoutInterval = 10.0 * 60
        return request
    }
    
    private func fetchData<T: Decodable>() async throws -> T {
        guard let request = createRequest() else { throw NetworkError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data: data, response: response)
    }
    
    private func uploadFiles<T: Decodable>(fileData: FileModelDR) async throws -> T {
        guard let url = URL(string: primaryURL) else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = primaryMethod.rawValue
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createMultipartBody(fileData: fileData, boundary: boundary)
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data: data, response: response)
    }
    
    private func createMultipartBody(fileData: FileModelDR, boundary: String) -> Data {
        var body = Data()
        
        for (index, file) in fileData.fileData.enumerated() {
            let fileName = "file\(index + 1)." + (fileData.fileURL[index].pathExtension.isEmpty ? fileData.attachmentType[index].rawValue : fileData.fileURL[index].pathExtension)
            let mimeType = AttachmentFileType(ext: fileData.fileURL[index].pathExtension).mimeType
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files[]\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(file)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        primaryParams?.forEach { key, value in
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)".data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    // MARK: - Response Handling
    
    private func handleResponse<T: Decodable>(data: Data?, response: URLResponse?) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.unknownError }
        guard let data = data else { throw NetworkError.unknownError }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try parseResponse(data: data)
        case 400:
            throw NetworkError.serverError(httpResponse.statusCode, extractMessage(from: data) ?? ErrorMessages.somethingWentWrong)
        case 401:
            handleUnauthorizedError(data: data)
            throw NetworkError.unauthorized
        case 402:
            handlePaymentRequiredError(data: data)
            throw NetworkError.paymentRequired
        default:
            throw NetworkError.serverError(httpResponse.statusCode, extractMessage(from: data) ?? ErrorMessages.somethingWentWrong)
        }
    }
    
    private func parseResponse<T: Decodable>(data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.parsingError(error)
        }
    }
    
    private func handleUnauthorizedError(data: Data) {
        let message = extractMessage(from: data) ?? ErrorMessages.session
        
        userSingleton.write(type: .isUserLogin, value: false)
        userSingleton.clearAllDataOnLogout()
        RootNavigator.shared.callHomeVC()
        showToast(message: message)
    }
    
    private func handlePaymentRequiredError(data: Data) {
        let message = extractMessage(from: data) ?? ErrorMessages.session
        
        AlertHelper.showAlert(title: "Alert Title", message: message, actions: [
            UIAlertAction(title: "OK", style: .default, handler: nil),
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ])
    }
    
    private func extractMessage(from data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let message = json["message"] as? String {
            return message.isEmpty ? ErrorMessages.somethingWentWrong : message
        }
        return nil
    }
}
