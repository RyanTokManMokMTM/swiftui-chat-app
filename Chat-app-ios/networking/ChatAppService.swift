//
//  ChatAppService.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 5/3/2023.
//

import SwiftUI

class ChatAppService : APIService {
    static let shared : APIService = ChatAppService()
    private init(){}
    private let Client = URLSession.shared
    private let Decoder = JSONDecoder()
    private let Encoder = JSONEncoder()

    
    func HealthCheck() async -> Result<HealthCheckResp,Error>{
        guard let url = URL(string: HTTP_HOST + APIEndPoint.HealthCheck.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    
        
        return await self.AsyncFetchAndDecode(request: request)
    }
    
    func UserSignIn(req : SignInReq) async -> Result<SignInResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.UserSignIn.rawValue) else {
            return .failure(APIError.badUrl)
        }
        print(url.absoluteString)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let body = try Encoder.encode(req)
            request.httpBody = body
        }catch {
            return .failure(APIError.badEncoding)
        }
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func UserSignUp(req : SignUpReq) async -> Result<SignUpResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.UserSignUp.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
       
        do {
            let body = try Encoder.encode(req)
            request.httpBody = body
        }catch {
            return .failure(APIError.badEncoding)
        }
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func GetUserInfo(req : GetUserInfoReq) async -> Result<GetUserInfoResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.UserProfile.rawValue + req.user_id.description) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        
        return await self.AsyncFetchAndDecode(request: request)
    }
    
    func UpdateUserInfo(req : UpdateUserInfoReq) async -> Result<UpdateUserInfoResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.UpdateUserProfile.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        return await self.AsyncPostAndDecode(request: request)
    }
    
    //TODO: Upload User Avatar
    func UploadUserAvatar(imgData : Data) async -> Result<UploadAvatarResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.UploadAvatar.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        //TODO: Add File here....
        //TODO: multipart/form-data
        
        let boundary = UUID().uuidString
        let httpBody = NSMutableData()
        
        httpBody.append(convertFileData(fieldName: "avatar", fileName: "\(UUID().uuidString).\(imgData.fileExtension)"  , mimeType: "image/\(imgData.fileExtension)", fileData: imgData, using: boundary))
        httpBody.appendString("--\(boundary)--")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        request.httpBody = httpBody as Data
//        request.addValue("content-type", forHTTPHeaderField: "application/json")

        return await self.AsyncPostAndDecode(request: request)
    }
    
    func SearchUser(email : String) async -> Result<SearchUserResp,Error> {
        guard var URLComp = URLComponents(string: HTTP_HOST + APIEndPoint.SearchUser.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        let queryItems = [
            URLQueryItem(name: "query", value: email)
        ]
        
        URLComp.queryItems = queryItems
        
        guard let finalURL = URLComp.url else {
            return .failure(APIError.badUrl)
        }
        print(finalURL.absoluteString)
        var request = URLRequest(url: finalURL)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return await AsyncFetchAndDecode(request: request)
    }
    
    func AddFriend(req : AddFriendReq) async -> Result<AddFriendResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.AddFriend.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        do {
            let body = try Encoder.encode(req)
            request.httpBody = body
        }catch {
            return .failure(APIError.badEncoding)
        }
        
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func DeleteFriend(req : DeleteFriendReq) async -> Result<DeleteFriendResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.DeleteFriend.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        do {
            let body = try Encoder.encode(req)
            request.httpBody = body
        }catch {
            return .failure(APIError.badEncoding)
        }
        
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func GetFriendList() async -> Result<GetFriendListResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.GetFriendList.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        print(url.absoluteString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        return await self.AsyncFetchAndDecode(request: request)
    }
    
    func CreateGroup(req : CreateGroupReq) async -> Result<CreateGroupResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.CreateGroup.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        do {
            let body = try Encoder.encode(req)
            request.httpBody = body
        }catch {
            return .failure(APIError.badEncoding)
        }
        
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func JoinGroup(req : JoinGroupReq) async -> Result<JoinGroupResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.JoinGroup.rawValue + req.group_id.description ) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func LeaveGroup(req : LeaveGroupReq) async -> Result<LeaveGroupResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.LeaveGroup.rawValue + req.group_id.description) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        
        
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func DeleteGroup(req : DeleteGroupReq) async -> Result<DeleteFriendResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.DeleteGroup.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        do {
            let body = try Encoder.encode(req)
            request.httpBody = body
        }catch {
            return .failure(APIError.badEncoding)
        }
        
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func GetGroupMembers(req : GetGroupMemberReq) async -> Result<GetGroupMembersResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.GetGroupMembers.rawValue + req.group_id.description) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func UploadGroupAvatar(imgData : Data,req : UploadGroupAvatarReq) async -> Result<UploadGroupAvatarResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.UploadGroupAvatar.rawValue + req.group_id.description) else {
            return .failure(APIError.badUrl)
        }
        
        let boundary = UUID().uuidString
        let httpbody = NSMutableData()
        
        httpbody.append(convertFileData(fieldName: "avatar", fileName: "\(UUID().uuidString).\(imgData.fileExtension)", mimeType: "image/\(imgData.fileExtension)", fileData: imgData, using: boundary))
        httpbody.appendString("--\(boundary)--")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        request.httpBody = httpbody as Data
       
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func UpdateGroupInfo(req : UpdateGroupInfoReq) async -> Result<UpdateGroupInfoResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.UpdateGroupInfo.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        do {
            let body = try Encoder.encode(req)
            request.httpBody = body
        }catch {
            return .failure(APIError.badEncoding)
        }
        
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func GetMessages(req : GetMessageReq) async -> Result<GetMessageResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.GetMessages.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        do {
            let body = try Encoder.encode(req)
            request.httpBody = body
        }catch {
            return .failure(APIError.badEncoding)
        }
        
        return await self.AsyncFetchAndDecode(request: request)
    }
    
    func DeleteMessage(req : DeleteMessageReq) async -> Result<DeleteFriendResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.DeleteMessage.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        do {
            let body = try Encoder.encode(req)
            request.httpBody = body
        }catch {
            return .failure(APIError.badEncoding)
        }
        
        return await self.AsyncPostAndDecode(request: request)
    }
    
    private func AsyncFetchAndDecode<ResponseType : Decodable>(request : URLRequest) async -> Result<ResponseType,Error>{
        
        do {
            let (data ,response) = try await Client.data(for: request)
            guard let statusCode = response as? HTTPURLResponse,200..<300 ~= statusCode.statusCode else{
                let errResp = try self.Decoder.decode(ErrorResp.self, from: data)
                return .failure(errResp)
            }
            
            if let decideData = try? self.Decoder.decode(ResponseType.self, from: data){
                return .success(decideData)
            }else{
                //MARK: this code need to status code block !!!
                let errResp = try self.Decoder.decode(ErrorResp.self, from: data)
               
                return .failure(errResp)
            }
        } catch {
           
            return .failure(error)
        }
      
    }
    
    

    
    private func AsyncPostAndDecode<ResponseType : Decodable>(request : URLRequest) async -> Result<ResponseType,Error> {
        
        do {
            let (data ,response) = try await Client.data(for: request)
            guard let statusCode = response as? HTTPURLResponse,200..<300 ~= statusCode.statusCode else{
                let errResp = try self.Decoder.decode(ErrorResp.self, from: data)
                print(errResp.message)
                return  .failure(errResp)
            }
            
            if let decideData = try? self.Decoder.decode(ResponseType.self, from: data){
                return .success(decideData)
            }else{
                //MARK: this code need to status code block !!!
                let errResp = try self.Decoder.decode(ErrorResp.self, from: data)
                return .failure(errResp)
            }
        }catch {
            return .failure(error)
        }
    }
    
    private func getUserToken() -> String {
        return UserDefaults.standard.string(forKey: "token") ?? ""
    }

}
