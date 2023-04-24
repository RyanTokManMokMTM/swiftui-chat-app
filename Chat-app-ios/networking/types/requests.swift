//
//  requests.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 5/3/2023.
//

import Foundation

struct HealthCheckResp : Decodable {
    let resp : String
}

struct SignUpReq : Encodable {
    let email : String
    let name : String
    let password : String
}

struct SignUpResp : Decodable {
    let code : UInt
    let token : String
    let expired_time : UInt
}

struct SignInReq : Encodable {
    let email : String
    let password : String
}

struct SignInResp : Decodable {
    let code : UInt
    let token : String
    let expired_time : UInt
    let user_info : UserProfile
    
}


struct GetUserInfoReq {
    let user_id : UInt?
    let uuid : String?
}

struct GetUserInfoResp : Decodable{
    let code : UInt
    let uuid : String
    let name : String
    let email : String
    let avatar : String
    let cover : String
}

struct GetUserProfileReq {
    let user_id : UInt?
    let uuid : String?
}

struct GetUserProfileResp : Decodable{
    let code : UInt
    let user_info : UserProfile
    var is_friend : Bool
}

struct UpdateUserInfoReq : Encodable {
    let name : String
}

struct UpdateUserInfoResp : Decodable {
    let code : UInt
}

struct UpdateStatusReq : Encodable {
    let status : String
}

struct UpdateStatusResp : Decodable {
    let code : UInt
}

struct UploadAvatarResp : Decodable {
    let code : UInt
    let path : String
}

struct UploadCoverResp : Decodable {
    let code : UInt
    let path : String
}

struct SearchUserResp : Decodable{
    let code : UInt
    let results : [SearchUserResult]?
}

struct SearchUserResult : Decodable{
    let user_info : UserProfile
    var is_friend : Bool
}

struct AddFriendReq : Encodable {
    let user_id : UInt
}

struct AddFriendResp : Decodable {
    let code : UInt
}

struct DeleteFriendReq : Encodable {
    let user_id : UInt
}

struct DeleteFriendResp : Decodable {
    let code : UInt
}

struct GetFriendListResp : Decodable {
    let friends : [UserProfile]
}

struct CreateGroupReq : Encodable {
    let group_name : String
    let members : [UInt]
    let avatar : String
}

struct CreateGroupResp : Decodable {
    let code : UInt
    let group_uuid : String
    let grou_avatar : String
}

struct JoinGroupReq {
    let group_id : UInt
}

struct JoinGroupResp : Decodable {
    let code : UInt
}

struct LeaveGroupReq {
    let group_id : UInt
}

struct LeaveGroupResp : Decodable {
    let code : UInt
}

struct DeleteGroupReq : Encodable {
    let group_id : UInt
}

struct DeleteGroupResp : Decodable {
    let code : UInt
}

struct GetGroupMemberReq  {
    let group_id : UInt
}

struct GetGroupMembersResp : Decodable {
    let code : UInt
    let member_list : [GroupMemberInfo]
}

struct SearchGroupResp : Decodable {
    let code : UInt
    let results : [FullGroupInfo]
}

struct GetGroupInfoByUUIDResp : Decodable{
    let code : UInt
    let result : FullGroupInfo
}

struct GroupMemberInfo : Decodable ,Identifiable{
    let id : UInt
    let uuid : String
    let name : String
//    let email : String
    let avatar : String
    let is_group_lead : Bool
    
    var AvatarURL : URL {
        return URL(string:RESOURCES_HOST + self.avatar)!
    }
}

struct FullGroupInfo : Decodable {
    let id : UInt
    let uuid : String
    let name : String
    let avatar : String
    let members : UInt
    let created_at : UInt
    var is_joined : Bool
    let is_owner : Bool
    
    var AvatarURL : URL {
        return URL(string:RESOURCES_HOST + self.avatar)!
    }
    
    var CreatedAt : Date {
        return Date(timeIntervalSince1970: TimeInterval(self.created_at))
    }
}

struct UpdateGroupInfoReq : Encodable {
    let group_id : UInt
    let group_name : String
}

struct UpdateGroupInfoResp : Decodable {
    let code : UInt
}

struct UploadGroupAvatarReq {
    let group_id : UInt
}

struct UploadGroupAvatarResp : Decodable {
    let code : UInt
}

struct GetUserGroups : Decodable{
    let code : UInt
    let groups : [GroupInfo]
}

struct GroupInfo : Decodable,Identifiable{
    let id : UInt
    let uuid : String
    let name : String
    let avatar : String
    let created_at : UInt
    
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST + self.avatar)!
    }
    
    var CreatedAt : Date {
        return Date(timeIntervalSince1970: TimeInterval(self.created_at))
    }
}

struct GetMessageReq : Encodable {
    let id : UInt
    let message_type : UInt
    let friend_id : UInt
}

struct GetMessageResp : Decodable {
    let code : UInt
    let message : [MessageUser]
}

struct MessageUser : Decodable {
    let id : UInt
    let from_id : UInt
    let to_id : UInt
    let content : String
    let content_type : UInt
    let message_type : UInt
    let create_at : UInt
}

struct DeleteMessageReq : Encodable{
    let msg_id : UInt
}

struct DeleteMessageResp : Decodable {
    let code : UInt
}


struct UploadImageReq : Encodable {
    let image_type : String
    let data : String
}

struct UploadImageResp : Decodable {
    let code : UInt
    let path : String
}

struct UploadFileReq : Encodable {
    let file_name : String
    let data : String
}

struct UploadFileResp : Decodable {
    let code : UInt
    let path : String
}

//MARK: STORIES
struct CreateStoryResp : Decodable {
    let code : UInt
    let story_id : uint
}

struct GetUserStoriesResp : Decodable {
    let code : UInt
    let story_ids : [UInt]
}

struct GetStoryInfoReq {
    let story_id : UInt
}
struct GetStoryInfoResp : Decodable {
    let code : UInt
    let story_id : UInt
    let media_url : String
    let create_at : UInt
}

struct DeleteStoryReq : Encodable {
    let story_id : UInt
}
struct DeleteStoryResp : Decodable {
    let code : UInt
}

struct GetActiveStoryResp : Decodable {
    let code : UInt
    let active_stories : [FriendStory]
}

struct FriendStory : Decodable,Identifiable{
    let id : UInt
    let uuid : String
    let name : String
    let avatar : String
    var is_seen : Bool
    let stories_ids : [UInt]
    
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST + self.avatar)!
    }
}
