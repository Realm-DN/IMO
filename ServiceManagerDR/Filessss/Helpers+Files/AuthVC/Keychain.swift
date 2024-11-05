//
//  Keychain.swift
//

import Foundation

let bundleID =  Bundle.main.bundleIdentifier ?? ""
struct KeychainItem {
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError
    }
    
    let service: String
    private(set) var account: String
    let accessGroup: String?
    
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    func readItem() throws -> String {
        var query = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status != errSecItemNotFound else {
            throw KeychainError.noPassword
        }
        guard status == noErr else {
            throw KeychainError.unhandledError
        }
        
        guard let existingItem = queryResult as? [String: AnyObject],
              let passwordData = existingItem[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: .utf8) else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return password
    }
    //MARK: - saveItem
    func saveItem(_ password: String) throws {
        let encodedPassword = password.data(using: .utf8)!
        
        do {
            try _ = readItem()
            
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?
            
            let query = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            guard status == noErr else {
                throw KeychainError.unhandledError
            }
        } catch KeychainError.noPassword {
            var newItem = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            guard status == noErr else {
                throw KeychainError.unhandledError
            }
        }
    }
    //MARK: - deleteItem
    func deleteItem() throws {
        let query = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unhandledError
        }
    }
    
    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
    
    static var currentUserIdentifier: String {
        return readItem(forAccount: "userIdentifier")
    }
    
    static var currentEmail: String {
        return readItem(forAccount: "email")
    }
    
    static var firstName: String {
        return readItem(forAccount: "firstName")
    }
    
    static var lastName: String {
        return readItem(forAccount: "lastName")
    }
    
    static func deleteUserIdentifierFromKeychain() {
        deleteItem(forAccount: "userIdentifier")
    }
    
    static func clearUUIDFromKeychain() {
        deleteItem(forAccount: "uuid")
    }
    
    static var deviceUUID: String {
        return readItem(forAccount: "uuid")
    }
    //MARK: - readItem
    private static func readItem(forAccount account: String) -> String {
        do {
            let storedIdentifier = try KeychainItem(service: bundleID, account: account).readItem()
            return storedIdentifier
        } catch {
            return ""
        }
    }
    
    private static func deleteItem(forAccount account: String) {
        do {
            try KeychainItem(service: bundleID, account: account).deleteItem()
        } catch {
            print("Unable to delete \(account) from keychain")
        }
    }
}
