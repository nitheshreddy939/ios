//
//  ContentView.swift
//  Nithesh
//
//  Created by rishi nareddy on 05/03/24.
//

import SwiftUI
import Alamofire

struct Item: Identifiable {
    let id: Int
    let listId: Int
    let name: String
}

struct ContentView: View {
    @State private var items: [Int: [Item]] = [:]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items.keys.sorted(), id: \.self) { listId in
                    Section(header: Text("List \(listId)")) {
                        ForEach(items[listId]!.sorted(by: { $0.name < $1.name })) { item in
                            Text(item.name)
                        }
                    }
                }
            }
            .navigationTitle("Items")
        }
        .onAppear {
            fetchData()
        }
    }
    
    private func fetchData() {
        let url = "https://fetch-hiring.s3.amazonaws.com/hiring.json"
        AF.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let jsonArray = value as? [[String: Any]] {
                    let itemsArray = jsonArray.compactMap { dict -> Item? in
                        guard let id = dict["id"] as? Int,
                              let listId = dict["listId"] as? Int,
                              let name = dict["name"] as? String,
                              !name.isEmpty else {
                            return nil
                        }
                        return Item(id: id, listId: listId, name: name)
                    }
                    self.items = Dictionary(grouping: itemsArray, by: { $0.listId })
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

