//
//  Database.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/15.
//


import Foundation

enum DbAction {
    case add
    case modify
    case delete
}

protocol Database {
    func setQuery(from: Any, to: Any)
    func saveChange(key: String, object: [String: Any], action: DbAction)
}
