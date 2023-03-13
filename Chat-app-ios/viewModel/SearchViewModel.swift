//
//  SearchViewModel.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/3/2023.
//

import Foundation

class SearchViewModel : ObservableObject {
    @Published var searchResponse : [SearchUserResult] = [SearchUserResult]()
    
    init() {
//        searchResponse.append(UserProfile(id: 1, uuid: "admin2", name: "test", email: "test@admin.com", avatar: "/default.jpg"))
//        searchResponse.append(UserProfile(id: 2, uuid: "admin1", name: "test", email: "test@admin.com", avatar: "/default.jpg"))
//        searchResponse.append(UserProfile(id: 3, uuid: "admin3", name: "test", email: "test@admin.com", avatar: "/default.jpg"))
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
