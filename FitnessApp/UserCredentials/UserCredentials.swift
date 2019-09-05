//
//  UserCredentials.swift
//  FitnessApp
//
//  Created by Simran Dhillon on 8/20/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation

struct UserCredentials {
    var username: String
    var password: String
}

enum KeychainError: Error {
    case noPassword
    case wrongPassword
    case error(status: OSStatus)
}


