# SwiftUI-Chat-APP
#### Overview:
~~This app is built for IOS only. The main purpose of building this app  is testing the instance message system which system is in progress.~~
This app is about real-time communication likes any chat app/ social app on the Internet. The application takes the references from Instegram/Messages/Wechat/QQ/Line/Discord, so that why the UI looks simlar to them xD.

#### Tech/Tool:
* SwiftUI - UI Framework
* UIKit - UIFramwork
* Swift
* Xcode
* CoreData
* Combine
* WebSocket
* WebRTC

#### Feture in App:
* User - `SignIn` / `Sigout` / `Register` / `profile update`
* Other User - `Search user` / `add friends`
* Group - `Search group` / `create group` / `join&leave group` / `update group info(if Owner)` / `Check members`
* Instance Story(Only available within 24Hours) - `Create Instance story` / `Check Friends Instance Story` / `like instance story` / `remove instance story` / `Shared story to any friends` / `check instance story seen user`
* Communication -  
  * Chat(Sigle Chat / Group Chat) - `Text`/`Image`/`Audio`/`Video`/`File`/`Sticker`
    * File - `Save to file`
    * Image - `Download and save to phone album`
    * Audio - `Save to disk` / `Listen in App`
    * Video - `Save to disk` / `Watch in App`
    * Sticker - `Check in Sticker store(add on sticker store/Remove from user sticker list)`
    * Instance Story(Signle chat only) - `View shared Instace story that is shared`
    * Support - `Reply Message`/`Resend Message`/`Recall Message`/`Delete Message`
  * Media Streaming chat
    * Audio
      * SFU(Mutliple-streming) - Work but not statble   
    * Video - **not stable**
      * SFU(Mutliple-streming) - **Work but not statble** 
* Sticker shop - `Add/Remove any sticker in store`
* CoreData - `Use for saving received message/GroupInfo/UserInfo as a cache`
  
#### Issue not yet fixed:
* RTC/SFU Black Ccreen Issue
* RTC/SFU Latency Issue
* RTC/SFU Video streaming track stuck issue

#### Feature if work on it again:
* Live Streaming
* More content type supported on Chatting - eg: URL, Hashtag, Tag People etc.
  
#### App Screen capture:
![app](./screen/updated-2024-0420.png)

