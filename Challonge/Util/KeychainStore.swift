//
//  KeychainStore.swift
//  Challonge
//
//  Created by Ashley Ng on 2/19/19.
//  Copyright © 2019 AshleyNg. All rights reserved.
//

import Foundation

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
    case string2DataConversionError
}

struct KeychainStore {
    private static let server = "challonge.com"
    
    static func fetchKey(forUsername username: String) throws -> String {
        var query = KeychainStore.query(withUsername: username)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        var queryResults: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResults) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status != errSecItemNotFound else {
            throw KeychainError.noPassword
        }
        guard status == noErr else {
            throw KeychainError.unhandledError(status: status)
        }
        
        guard let existingItem = queryResults as? [String: AnyObject],
            let apiKeyData = existingItem[kSecValueData as String] as? Data,
            let apiKey = String(data: apiKeyData, encoding: String.Encoding.utf8) else {
                throw KeychainError.unexpectedPasswordData
        }
        return apiKey
    }
    
    static func saveApiKey(_ key: String, forUsername username: String) throws {
        guard let encodedKey = key.data(using: String.Encoding.utf8) else {
            throw KeychainError.string2DataConversionError
        }
        
        do {
            try _ = KeychainStore.fetchKey(forUsername: username)
            
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedKey as AnyObject?
            
            let status = SecItemUpdate(KeychainStore.query(withUsername: username) as CFDictionary, attributesToUpdate as CFDictionary)
            
            guard status == noErr else {
                throw KeychainError.unhandledError(status: status)
            }
        } catch KeychainError.noPassword {
            var newItem = KeychainStore.query(withUsername: username)
            newItem[kSecValueData as String] = encodedKey as AnyObject?
            
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            guard status == noErr else {
                throw KeychainError.unhandledError(status: status)
            }
        }
    }
    
    static func deleteApiKey(withUsername username: String) throws {
        let query = KeychainStore.query(withUsername: username)
        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    private static func query(withUsername username: String) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = username as AnyObject?
        query[kSecAttrService as String] = KeychainStore.server as AnyObject?
        return query
    }
}
