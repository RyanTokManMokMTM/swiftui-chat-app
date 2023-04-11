//
//  apiService.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 15/2/2023.
//

import Foundation


let HTTP_HOST = "http://127.0.0.1:8000/api/v1"
let WS_HOST = "ws://127.0.0.1:8000/ws"
let RESOURCES_HOST = "http://127.0.0.1:8000/resources"


protocol APIService {
    func HealthCheck() async -> Result<HealthCheckResp,Error>
    func UserSignIn(req : SignInReq) async -> Result<SignInResp,Error>
    func UserSignUp(req : SignUpReq) async -> Result<SignUpResp,Error>
    func GetUserInfo(req : GetUserInfoReq) async -> Result<GetUserInfoResp,Error>
    func UpdateUserInfo(req : UpdateUserInfoReq) async -> Result<UpdateUserInfoResp,Error>
    func UploadUserAvatar(imgData : Data) async -> Result<UploadAvatarResp,Error>
    func SearchUser(email : String) async -> Result<SearchUserResp,Error>
    
    func AddFriend(req : AddFriendReq) async -> Result<AddFriendResp,Error>
    func DeleteFriend(req : DeleteFriendReq) async -> Result<DeleteFriendResp,Error>
    func GetFriendList() async -> Result<GetFriendListResp,Error>
    
    func CreateGroup(req : CreateGroupReq) async -> Result<CreateGroupResp,Error>
    func JoinGroup(req : JoinGroupReq) async -> Result<JoinGroupResp,Error>
    func LeaveGroup(req : LeaveGroupReq) async -> Result<LeaveGroupResp,Error>
    func DeleteGroup(req : DeleteGroupReq) async -> Result<DeleteFriendResp,Error>
    func GetGroupMembers(req : GetGroupMemberReq) async -> Result<GetGroupMembersResp,Error>
    func UploadGroupAvatar(imgData : Data,req : UploadGroupAvatarReq) async -> Result<UploadGroupAvatarResp,Error>
    func UpdateGroupInfo(req : UpdateGroupInfoReq) async -> Result<UpdateGroupInfoResp,Error>
    func GetUserGroups() async -> Result<GetUserGroups,Error>
    
    func GetMessages(req : GetMessageReq) async -> Result<GetMessageResp,Error>
    func DeleteMessage(req : DeleteMessageReq) async -> Result<DeleteFriendResp,Error>
    
    func UploadImage(req : UploadImageReq) async -> Result<UploadImageResp,Error>
    func UploadFile(req : UploadFileReq) async -> Result<UploadFileResp,Error>
}

enum APIError : Error, CustomNSError{
    case badUrl
    case badResponse
    case badEncoding
    
    case apiError
    case invalidEndpoint
    case invalidResponse
    case noData
    case serializationError
    
    var localizedDescription : String {
        switch self {
        case .apiError: return "Failed to fetch data"
        case .invalidEndpoint: return "Invalid endpoint"
        case .invalidResponse: return "Invalid response"
        case .noData: return "No data"
        case .serializationError: return "Failed to decode data"
        case .badUrl: return "Invalid URL"
        case .badResponse: return "Get a bad response"
        case .badEncoding: return "Failed to encode data"
        }
    }
    var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey : localizedDescription]
    }
}

enum APIEndPoint : String,CaseIterable {
    case HealthCheck
    case UserSignIn
    case UserSignUp
    case UserProfile
    case UpdateUserProfile
    case UploadAvatar
    case SearchUser
    
    case AddFriend
    case DeleteFriend
    case GetFriendList
    
    case CreateGroup
    case JoinGroup
    case LeaveGroup
    case DeleteGroup
    case GetGroupMembers
    case UploadGroupAvatar
    case UpdateGroupInfo
    case GetUserGroups
    
    case GetMessages
    case DeleteMessage
    
    case UploadImage
    case UploadFile
    var rawValue: String {
        switch self {
        case .HealthCheck : return  "/ping"
        case .UserSignUp : return  "/user/signup"
        case .UserSignIn : return "/user/signin"
        case .UserProfile : return "/user/profile"
        case .UpdateUserProfile : return "/user/profile/"
        case .UploadAvatar : return "/user/avatar"
        case .SearchUser : return "/user/search"
            
            
        case .AddFriend : return "/user/friend"
        case .DeleteFriend : return "/user/friend"
        case .GetFriendList : return "/user/friends"
            
        case .CreateGroup : return "/group"
        case .JoinGroup : return "/group/join/"
        case .LeaveGroup : return "/group/leave/"
        case .DeleteGroup : return "/group"
        case .GetGroupMembers : return "/group/members/"
        case .UploadGroupAvatar: return "/group/avatar/:grou_id"
        case .UpdateGroupInfo: return "/group/update"
        case .GetUserGroups: return "/group"
            
            
        case .GetMessages : return "/message"
        case .DeleteMessage : return "/message"
            
        case .UploadImage : return "/file/image/upload"
        case .UploadFile : return "/file/document/upload"
        }
    }
}
