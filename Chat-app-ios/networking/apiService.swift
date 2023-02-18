//
//  apiService.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 15/2/2023.
//

import Foundation

protocol APIService {
    func UserSignIn() async 
    func UserSignUp() async
    func GetUserInfo() async
    func UpdateUserInfo() async
}
