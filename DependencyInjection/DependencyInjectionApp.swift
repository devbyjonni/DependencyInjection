//
//  DependencyInjectionApp.swift
//  DependencyInjection
//
//  Created by Jonni Akesson on 2023-02-26.
//

import SwiftUI

@main
struct DependencyInjectionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(vm: DependencyProvider.viewModel)
        }
    }
}
