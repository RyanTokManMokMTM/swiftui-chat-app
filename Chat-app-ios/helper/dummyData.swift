//
//  dummyData.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 20/2/2023.
//

import SwiftUI

let dummyUserID = 9999
let dummyActiveChat : [ContentInfo] = [
    ContentInfo(id: 1, name: "Jacksontmm", avatar: "https://i.ibb.co/zf5XCDm/3fef478737ea0f4abe5d69db3e25d71e.jpg", lastMessage: "hi", lastSent: Calendar.current.date(byAdding: .day, value: 0, to: .now)!, isOnline: true),
    ContentInfo(id: 2, name: "Alice", avatar: "https://i.ibb.co/hMfxNYb/43a673ce2544e8be031f1f943b83a5fd.jpg", lastMessage: "testing", lastSent: Calendar.current.date(byAdding: .day, value: -5, to: .now)!, isOnline: false),
    ContentInfo(id: 3, name: "Alex", avatar: "https://i.ibb.co/HdM1qGX/58ea4a25a5cdad79f43c80d8e23f2d87.jpg", lastMessage: "where are u", lastSent: Calendar.current.date(byAdding: .day, value: -7, to: .now)!, isOnline: false),
    ContentInfo(id:4,name: "Joyce", avatar: "https://i.ibb.co/PF47Gdm/56803700ba960b5bd8b7c1ff33f4547d.jpg", lastMessage: "good to see u", lastSent: Calendar.current.date(byAdding: .day, value: -9, to: .now)!, isOnline: true),
    ContentInfo(id: 5, name: "AKA.TW", avatar: "https://i.ibb.co/nrHVGbT/dbe2be89a206511fdc76c6e7fcc504f5.jpg", lastMessage: "nice to meet you", lastSent: Calendar.current.date(byAdding: .day, value: -13, to: .now)!, isOnline: true),
    ContentInfo(id: 6, name: "Elsa", avatar: "https://i.ibb.co/gZ12G1K/ef2eb8f3a9becd5c9dd3c7b71c8be999.jpg", lastMessage: "please hand me your paper tomorrow", lastSent: Calendar.current.date(byAdding: .day, value: -17, to: .now)!, isOnline: true),
    ContentInfo(id: 7, name: "Slow Black", avatar: "https://i.ibb.co/xDdf963/f988541177973cb615de17b3521c8ab3.jpg", lastMessage: "hello,i saw you on abc streen this morning! Were u there this morning?", lastSent: Calendar.current.date(byAdding: .day, value: -20, to: .now)!, isOnline: false),
    ContentInfo(id: 8, name: "Catter", avatar: "https://i.ibb.co/9Gw85Jt/2e55b6a012057715ab7470ef78c39521.jpg", lastMessage: "Hello,my name is Catter, what's ur name?", lastSent: Calendar.current.date(byAdding: .day, value: -25, to: .now)!, isOnline: true),
]

let dummyActiveStory : [ContentStory] = [
    ContentStory(id: 1, name: "Jacksontmm", avatar: "https://i.ibb.co/zf5XCDm/3fef478737ea0f4abe5d69db3e25d71e.jpg", isRead: false),
    ContentStory(id: 2, name: "Alice", avatar: "https://i.ibb.co/hMfxNYb/43a673ce2544e8be031f1f943b83a5fd.jpg", isRead: false),
    ContentStory(id: 3, name: "Alex", avatar: "https://i.ibb.co/HdM1qGX/58ea4a25a5cdad79f43c80d8e23f2d87.jpg", isRead: true),
    ContentStory(id:4,name: "Joyce", avatar: "https://i.ibb.co/PF47Gdm/56803700ba960b5bd8b7c1ff33f4547d.jpg", isRead: true),
    ContentStory(id: 5, name: "AKA.TW", avatar: "https://i.ibb.co/nrHVGbT/dbe2be89a206511fdc76c6e7fcc504f5.jpg", isRead: true),
    ContentStory(id: 6, name: "Elsa", avatar: "https://i.ibb.co/gZ12G1K/ef2eb8f3a9becd5c9dd3c7b71c8be999.jpg", isRead: true),
    ContentStory(id: 7, name: "Slow Black", avatar: "https://i.ibb.co/xDdf963/f988541177973cb615de17b3521c8ab3.jpg", isRead: true),
    ContentStory(id: 8, name: "Catter", avatar: "https://i.ibb.co/9Gw85Jt/2e55b6a012057715ab7470ef78c39521.jpg", isRead: true),
]


let dummyContentList : [ContentUser] = [
    ContentUser(name: "Jacksontmm", avatar: "https://i.ibb.co/zf5XCDm/3fef478737ea0f4abe5d69db3e25d71e.jpg"),
    ContentUser(name: "Alice", avatar: "https://i.ibb.co/hMfxNYb/43a673ce2544e8be031f1f943b83a5fd.jpg"),
    ContentUser(name: "Alex", avatar: "https://i.ibb.co/HdM1qGX/58ea4a25a5cdad79f43c80d8e23f2d87.jpg"),
    ContentUser(name: "Joyce", avatar: "https://i.ibb.co/PF47Gdm/56803700ba960b5bd8b7c1ff33f4547d.jpg"),
    ContentUser(name: "AKA.TW", avatar: "https://i.ibb.co/nrHVGbT/dbe2be89a206511fdc76c6e7fcc504f5.jpg"),
    ContentUser(name: "Elsa", avatar: "https://i.ibb.co/gZ12G1K/ef2eb8f3a9becd5c9dd3c7b71c8be999.jpg"),
    ContentUser(name: "Slow Black", avatar: "https://i.ibb.co/xDdf963/f988541177973cb615de17b3521c8ab3.jpg"),
    ContentUser(name: "Catter", avatar: "https://i.ibb.co/9Gw85Jt/2e55b6a012057715ab7470ef78c39521.jpg"),
]
