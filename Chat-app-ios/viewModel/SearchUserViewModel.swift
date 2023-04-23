//
//  SearchViewModel.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/3/2023.
//

import Foundation

class SearchUserViewModel : ObservableObject {
    @Published var searchResponse : [SearchUserResult] = [SearchUserResult]()
    
    init() {
    }
    
    func GetSearchResult(keyword : String) async{
        if keyword.isEmpty {
            return
        }
    
        let resp = await ChatAppService.shared.SearchUser(email: keyword)
        switch resp {
        case .success(let data):
            if data.code == 200 {
                DispatchQueue.main.async {
                    self.searchResponse = data.results!
                }

            }
        case .failure(let err):
            print(err.localizedDescription)
        }
        
//        ChatAppService.shared
    }
}

class SearchGroupViewModel : ObservableObject {
    @Published var searchResponse : [FullGroupInfo] = [FullGroupInfo]()
    
    init() {
    }
    
    func GetSearchResult(keyword : String) async{
        if keyword.isEmpty {
            return
        }
    
        let resp = await ChatAppService.shared.SearchGroup(query: keyword)
        
        switch resp {
        case .success(let data):
            if data.code == 200 {
                DispatchQueue.main.async {
                    self.searchResponse = data.results
                }

            }
        case .failure(let err):
            print(err.localizedDescription)
        }
        
//        ChatAppService.shared
    }
}
