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
        guard let url = URL(string: HTTP_HOST + APIEndPoint.GetUserInfo.rawValue) else {
            return .failure(APIError.badUrl)
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if req.user_id != nil{
            components.queryItems = [
                URLQueryItem(name: "id", value: req.user_id!.description)
            ]
        }else {
            components.queryItems = [
                URLQueryItem(name: "uuid", value: req.uuid!)
            ]
        }

        var request = URLRequest(url: URL(string : components.string ?? "")!)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return await self.AsyncFetchAndDecode(request: request)
    }
    
    func GetUserProfileInfo(req : GetUserProfileReq) async -> Result<GetUserProfileResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.UserProfile.rawValue) else {
            return .failure(APIError.badUrl)
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        if req.user_id != nil{
            components.queryItems = [
                URLQueryItem(name: "id", value: req.user_id!.description)
            ]
        }else {
            components.queryItems = [
                URLQueryItem(name: "uuid", value: req.uuid!)
            ]
        }
      
//        print(components.string)
        var request = URLRequest(url: URL(string : components.string ?? "")!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return await self.AsyncFetchAndDecode(request: request)
    }
    
    func UpdateUserInfo(req : UpdateUserInfoReq) async -> Result<UpdateUserInfoResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.UpdateUserProfile.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        do {
            let body = try self.Encoder.encode(req)
            request.httpBody = body
        }catch {
            return .failure(APIError.badEncoding)
        }
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func UpdateStatusMessage(req : UpdateStatusReq) async -> Result<UpdateStatusResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.UpdateStatus.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        
        do {
            let body = try self.Encoder.encode(req)
            request.httpBody = body
        }catch {
            return .failure(APIError.badEncoding)
        }
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
    
    func UploadUserCover(imgData : Data) async -> Result<UploadCoverResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.UploadCover.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        //TODO: Add File here....
        //TODO: multipart/form-data
        
        let boundary = UUID().uuidString
        let httpBody = NSMutableData()
        
        httpBody.append(convertFileData(fieldName: "cover", fileName: "\(UUID().uuidString).\(imgData.fileExtension)"  , mimeType: "image/\(imgData.fileExtension)", fileData: imgData, using: boundary))
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
    
    func SearchGroup(query : String) async -> Result<SearchGroupResp,Error> {
        guard let url = URL(string : HTTP_HOST + APIEndPoint.SearchGroup.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        
        var component = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        component.queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        
        guard let queryURL = component.url else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: queryURL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        
        return await self.AsyncFetchAndDecode(request: request)
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
    
    func GetUserGroups() async -> Result<GetUserGroups, Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.GetUserGroups.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        
        return await self.AsyncFetchAndDecode(request: request)
    }
    
    func GetGroupInfoByUUID(uuid : String) async -> Result<GetGroupInfoByUUIDResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.GetGroupInfoByUUID.rawValue + uuid) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return await self.AsyncFetchAndDecode(request: request)
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
    
    func UploadImage(req : UploadImageReq) async -> Result<UploadImageResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.UploadImage.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
           let body = try self.Encoder.encode(req)
            request.httpBody = body
        } catch (let err){
            print(err.localizedDescription)
            return .failure(APIError.badEncoding)
        }
        
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func UploadFile(req : UploadFileReq,fileExt : String) async -> Result<UploadFileResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.UploadFile.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        let boundary = UUID().uuidString
        let httpBody = NSMutableData()
        
        let mimeType = getMintype(fileType: fileExt)
        if mimeType.isEmpty {
            return .failure(APIError.badParameter)
        }
        
        httpBody.append(convertFileData(fieldName: "file", fileName: req.file_name  , mimeType: mimeType, fileData: req.data, using: boundary))
        httpBody.appendString("--\(boundary)--")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        request.httpBody = httpBody as Data
        
        
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func CreateStory(mediaData : Data) async -> Result<CreateStoryResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.AddStory.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        let boundary = UUID().uuidString
        let httpBody = NSMutableData()
        
        httpBody.append(convertFileData(fieldName: "story_media", fileName: "\(UUID().uuidString).\(mediaData.fileExtension)"  , mimeType: "image/\(mediaData.fileExtension)", fileData: mediaData, using: boundary))
        httpBody.appendString("--\(boundary)--")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        request.httpBody = httpBody as Data
        
        //Image Here
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func DeleteStory(req : DeleteStoryReq) async  -> Result<DeleteStoryResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.DeleteStory.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        
        do {
           let body = try self.Encoder.encode(req)
            request.httpBody = body
        } catch (let err){
            print(err.localizedDescription)
            return .failure(APIError.badEncoding)
        }
        
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func GetUserStories() async  -> Result<GetUserStoriesResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.GetUserStories.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
       
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func GetActiveStories() async  -> Result<GetActiveStoryResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.GetActiveStories.rawValue) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.getUserToken())", forHTTPHeaderField: "Authorization")
        return await self.AsyncPostAndDecode(request: request)
    }
    
    func GetStoryInfo(storyID : UInt) async  -> Result<GetStoryInfoResp,Error> {
        guard let url = URL(string: HTTP_HOST + APIEndPoint.GetStoryInfo.rawValue + storyID.description) else {
            return .failure(APIError.badUrl)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return await self.AsyncFetchAndDecode(request: request)
    }
    
    
    func DownloadTask(fileURL : URL) async -> Result<URL,Error>{
        return await AsyncDownload(url: fileURL)
    }
    
    private func AsyncDownload(url : URL) async -> Result<URL,Error> {
        do {
            let (file,response) = try await self.Client.download(from: url)
            guard let statusCode = response as? HTTPURLResponse,200..<300 ~= statusCode.statusCode else{
                return .failure(APIError.badResponse)
            }
            return .success(file)
        } catch {
           
            return .failure(error)
        }
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
    
    private func getMintype(fileType : String) -> String {
        switch fileType {
        case "doc":return "application/msword"
        case "docx":return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls":return "application/vnd.ms-excel"
        case "xlsx":return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "ppt":return "application/vnd.ms-powerpoint"
        case "pptx" : return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "pdf" : return "application/pdf"
        case "rtf" : return "application/rtf"
            
        case "gif": return "image/gif"
        case "jpeg" : return "image/jpeg"
        case "png" : return "image/png"
        case "tiff" : return "image/tiff"
        case "bmp" : return "image/bmp"
            
        case "txt":return "text/plain"
            
        case "mp3":return "audio/mpeg"
        case "wav":return "audio/x-wav"
        case "m4a":return "audio/x-m4a"
            
        case "mp4":return "video/mp4"
        case "mpg","mpe","mpeg" : return "video/mpeg"
        case "qt","mov" : return "video/quicktime"
        case "m4v" : return "video/x-m4v"
        case "wmv" : return "video/x-ms-wmv"
        case "avi" : return "video/x-msvideo"
        default:
            return ""
        }
    }

}
