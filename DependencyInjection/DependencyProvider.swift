//
//  DependencyProvider.swift
//  DependencyInjection
//
//  Created by Jonni Akesson on 2023-02-26.
//

import Foundation

struct DependencyProvider {
    static var service:  Service {
        return Service()
    }

    static var viewModel: ContentViewModel {
        return ContentViewModel(service: self.service)
    }
}
