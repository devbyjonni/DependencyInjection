//
//  ContentView.swift
//  DependencyInjection
//
//  Created by Jonni Akesson on 2023-02-26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var vm: ContentViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.users) { user in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(user.name)")
                            .font(.headline)
                        Text("\(user.email)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Dependency ")
        }
        .task {
            //await vm.fetchJSONWithAsyncAwait()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(vm: ContentViewModel(service: Service()))
    }
}

