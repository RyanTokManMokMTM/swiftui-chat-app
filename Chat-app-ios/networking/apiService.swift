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
    func GetUserProfileInfo(req : GetUserProfileReq) async -> Result<GetUserProfileResp,Error>
    func UpdateUserInfo(req : UpdateUserInfoReq) async -> Result<UpdateUserInfoResp,Error>
    func UpdateStatusMessage(req : UpdateStatusReq) async -> Result<UpdateStatusResp,Error>
    func UploadUserAvatar(imgData : Data) async -> Result<UploadAvatarResp,Error>
    func UploadUserCover(imgData : Data) async -> Result<UploadCoverResp,Error>
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
    func SearchGroup(query : String) async -> Result<SearchGroupResp,Error>
    func GetGroupInfoByUUID(uuid : String) async -> Result<GetGroupInfoByUUIDResp,Error>
    
    func GetMessages(req : GetMessageReq) async -> Result<GetMessageResp,Error>
    func DeleteMessage(req : DeleteMessageReq) async -> Result<DeleteFriendResp,Error>
    
    func UploadImage(req : UploadImageReq) async -> Result<UploadImageResp,Error>
    func UploadFile(req : UploadFileReq,fileExt : String) async -> Result<UploadFileResp,Error>
     
    func CreateStory(mediaData : Data) async -> Result<CreateStoryResp,Error>
    func DeleteStory(req : DeleteStoryReq) async  -> Result<DeleteStoryResp,Error>
    func GetUserStories() async  -> Result<GetUserStoriesResp,Error>
    func GetActiveStories() async  -> Result<GetActiveStoryResp,Error>
    func GetStoryInfo(storyID : UInt) async  -> Result<GetStoryInfoResp,Error>
    
    func DownloadTask(fileURL : URL) async -> Result<URL,Error>
}

enum APIError : Error, CustomNSError{
    case badUrl
    case badResponse
    case badEncoding
    case badParameter
    
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
        case .badParameter : return "Invalid Parameter"
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
    case GetUserInfo
    case UpdateUserProfile
    case UpdateStatus
    case UploadAvatar
    case UploadCover
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
    case SearchGroup
    case GetGroupInfoByUUID
    
    case GetMessages
    case DeleteMessage
    
    case UploadImage
    case UploadFile
    
    case AddStory
    case DeleteStory
    case GetUserStories
    case GetActiveStories
    case GetStoryInfo
    
    var rawValue: String {
        switch self {
        case .HealthCheck : return  "/ping"
        case .UserSignUp : return  "/user/signup"
        case .UserSignIn : return "/user/signin"
        case .UserProfile : return "/user/profile"
        case .UpdateStatus : return "/user/status"
        case .UpdateUserProfile : return "/user/info/"
        case .UploadAvatar : return "/user/avatar"
        case .UploadCover : return "/user/cover"
        case .SearchUser : return "/user/search"
        case .GetUserInfo : return "/user/info"
        
        case .AddFriend : return "/user/friend"
        case .DeleteFriend : return "/user/friend"
        case .GetFriendList : return "/user/friends"
            
        case .CreateGroup : return "/group"
        case .JoinGroup : return "/group/join/"
        case .LeaveGroup : return "/group/leave/"
        case .DeleteGroup : return "/group"
        case .GetGroupMembers : return "/group/members/"
        case .UploadGroupAvatar: return "/group/avatar/"
        case .UpdateGroupInfo: return "/group/update"
        case .GetUserGroups: return "/group"
        case .SearchGroup : return "/group/search"
        case .GetGroupInfoByUUID : return "/group/info/uuid/"
            
            
        case .GetMessages : return "/message"
        case .DeleteMessage : return "/message"
            
        case .UploadImage : return "/file/image/upload"
//        case .UploadFile : return "/file/document/upload"
        case .UploadFile : return "/file/upload"
            
        case .AddStory: return "/story"
        case .DeleteStory: return "/story"
        case .GetUserStories: return "/stories"
        case .GetActiveStories: return "/stories/active"
        case .GetStoryInfo: return "/story/"
        }
    }
}

enum UploadFileType : String,CaseIterable{
    case text
    case image
    case audio
    case video
    case binary
    
    var rawValue: String {
        switch self {
        case .text : return "text" //reable text
        case .image : return "image" // any image
        case .audio : return "audio" // any audio
        case .video : return "video" // any video
        case .binary : return "application" //other
        }
    }
}



