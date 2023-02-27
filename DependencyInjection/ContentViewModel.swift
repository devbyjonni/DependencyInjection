//
//  ContentViewModel.swift
//  DependencyInjection
//
//  Created by Jonni Akesson on 2023-02-26.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {
    private let service: any Servicing
    private var cancellaables = Set<AnyCancellable>()
    
    @Published var users: [User] = []
    
    init(service: some Servicing) {
        self.service = service
        // fetchDataWithCompletion()
        fetchDataCombine()
    }
    
    private func fetchDataWithCompletion() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        service.getData(url: url) { (result: Result<[User], APIError>) in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self.users = users
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchDataCombine() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        
        service.getData(url: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] users in
                self?.users = users
            })
            .store(in: &cancellaables)
    }
    
    @MainActor
    func fetchDataWithAsync() async {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        do {
            self.users = try await service.getData(url: url)
        } catch {
            print(error.localizedDescription)
        }
    }
}
