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

let dummyChattingMessageRoom1 : [MessageData] = [
    MessageData(sender: 1, content: "hello!", message_type: 1, content_type: 1, PicURL: ""),
    MessageData(sender: dummyUserID, content: "hello! who are your?", message_type: 1, content_type: 1, PicURL: ""),
    MessageData(sender: dummyUserID, content: "Did we meet before?", message_type: 1, content_type: 1, PicURL: ""),
    MessageData(sender: 1, content: "Yes! I met you in school restaurant this morning.", message_type: 1, content_type: 1, PicURL: ""),
    MessageData(sender: 1, content: "My name is jackson, and what's your name?", message_type: 1, content_type: 1, PicURL: ""),
    MessageData(sender: dummyUserID, content: "Oh! I remember you, You are the girl i met this morning!. My name is Tom! Nice to meet you!", message_type: 1, content_type: 1, PicURL: ""),
    MessageData(sender: dummyUserID, content: "Oh! I remember you, You are the girl i met this morning!. My name is Tom! Nice to meet you!", message_type: 1, content_type: 1, PicURL: ""),
    MessageData(sender: 1, content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam ut felis quis eros rhoncus fermentum ut tincidunt libero. Cras at dui id libero ultricies tristique. Mauris eu commodo odio. Phasellus laoreet quam purus, ac pharetra odio finibus nec. Proin sit amet purus non justo accumsan venenatis vitae id quam. Curabitur vitae nunc a ipsum placerat congue. Sed efficitur dictum dolor, quis iaculis massa hendrerit non.", message_type: 1, content_type: 1, PicURL: ""),
    MessageData(sender: 1, content: "Integer tincidunt purus turpis, eu sollicitudin leo dignissim et. Aliquam erat volutpat. Pellentesque dapibus auctor tempor. Phasellus ut lacinia felis. Donec at facilisis lorem. Nam sodales vitae magna non pharetra. Nam tempus sed nisl in porta. Ut vitae orci neque. Phasellus tincidunt convallis sollicitudin. Duis gravida malesuada urna non tempus. In ut lectus elit. Nunc bibendum interdum posuere. Aenean lorem magna, tristique eu augue nec, aliquam vestibulum ante. Etiam a convallis elit. Interdum et malesuada fames ac ante ipsum primis in faucibus. Aenean sed arcu auctor, accumsan eros a, feugiat tellus.", message_type: 1, content_type: 1, PicURL: ""),
    MessageData(sender: 1, content: "Praesent nec ligula ut orci faucibus malesuada. Sed vestibulum, ipsum sed lacinia gravida, lacus odio laoreet augue, at elementum lacus elit et tortor. Proin eget efficitur ligula, eget iaculis ipsum. Nam rhoncus eleifend leo in hendrerit. Nulla sagittis dignissim diam ut semper. Nunc vel venenatis turpis. Integer in enim ac dui pellentesque blandit vel fermentum magna. Quisque condimentum metus ipsum, non accumsan enim pretium vitae. Vivamus nec metus erat. Fusce tincidunt ex ut volutpat ultrices. Nam laoreet turpis ac ornare vulputate. Quisque scelerisque nisi purus, vitae mattis sapien rhoncus ut. Duis purus mauris, semper vel cursus at, luctus et purus. Nam dictum, mauris quis tincidunt elementum, neque augue faucibus nunc, quis sodales massa quam sit amet diam. Nunc vestibulum gravida porta.", message_type: 1, content_type: 1,PicURL: ""),
    MessageData(sender: dummyUserID, content: "Mauris mauris nisi, auctor at tortor eget, tempor rhoncus sapien. Donec non congue dui. Sed imperdiet est lectus, et semper erat pellentesque vel. Curabitur erat leo, facilisis interdum urna in, interdum ullamcorper arcu. Maecenas sed cursus erat, sed scelerisque neque. Phasellus nec ante ut nulla congue varius. Nunc sit amet elit eget metus tempor mattis. Nunc at maximus metus. Integer facilisis gravida purus, in ultrices magna rutrum non. Etiam at consequat arcu. Nam sollicitudin, sapien vitae eleifend sagittis, ante urna hendrerit tellus, et lacinia sem augue ut tellus. Sed ullamcorper fringilla elit, vel sollicitudin justo semper eu. Praesent bibendum sed ligula non congue. Phasellus egestas odio et purus fringilla lobortis. Etiam non lorem risus. Integer venenatis est vitae nulla tincidunt posuere.", message_type: 1, content_type: 1, PicURL: ""),
    MessageData(sender: 1, content: "See ya!", message_type: 1, content_type: 1, PicURL: ""),
    MessageData(sender: dummyUserID, content: "bye!", message_type: 1, content_type: 1, PicURL: ""),
    MessageData(sender: 1, content: "", message_type: 1, content_type: 2, PicURL: "https://i.ibb.co/qFJhMN5/b84a5c20afa4c9352e875a3306b30b02.jpg"),
    MessageData(sender: dummyUserID, content: "", message_type: 1, content_type: 2, PicURL: "https://i.ibb.co/tZJKF5D/346fc7f9b4f48771c8ea0353cf4f901b.jpg"),
    MessageData(sender: dummyUserID, content: "", message_type: 1, content_type: 2, PicURL: "https://i.ibb.co/gt4dvNs/c3e3efefa98a895e0e3cc5b677b6d627.jpg"),
    MessageData(sender: 1, content: "thx!", message_type: 1, content_type: 1, PicURL: ""),
]

