//
//  User.swift
//  DependencyInjection
//
//  Created by Jonni Akesson on 2023-02-26.
//

import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let name, username, email: String
}
