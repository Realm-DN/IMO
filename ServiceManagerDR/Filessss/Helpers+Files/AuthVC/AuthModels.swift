//
//  AuthModels.swift
// 

import Foundation

enum AuthType {
    case login
    case register
}

enum SocialMedia {
    case apple
    case google
    case facebook
}

struct SocialInfo {
    var firstName: String?
    var lastName: String?
    var email: String?
    var socialID: String?
    var type: String = ""
    
    init(firstName: String?, lastName: String?, email: String?, socialID: String?, type: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.socialID = socialID
        self.type = type
    }
}

struct LoginInfo {
    var email: String?
    var password: String?
    init(email: String?, password: String?) {
        self.password = password
        self.email = email
    }
}

struct RegisterInfo {
    var full_name: String?
    var email: String?
    var password: String?
    var username: String?
    init(email: String?, password: String?, username: String?, full_name: String?) {
        self.password = password
        self.email = email
        self.username = username
        self.full_name = full_name
    }
}
