//
//  UserContentView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/3/2023.
//

import SwiftUI

struct UserContentView: View {
    var profile : UserProfile
    @Binding var isFriend : Bool
    var body: some View {
        VStack{
            Spacer()
            Info()
                .padding(.horizontal,10)
                .offset(y:-25)
                .background(Color("card").clipShape(CustomConer(coners: .topRight)))
                .edgesIgnoringSafeArea(.all)
        }
        .edgesIgnoringSafeArea(.all)
        .background(
            AsyncImage(url: self.profile.CoverURL, content: { img in
            img
//                .resizable()
                .aspectRatio(contentMode: .fill)
              
            
            
        }, placeholder: {
            ProgressView()
                .frame(width:80,height:80)
        }))
        
    }
    
    @ViewBuilder
    private func Info() -> some View {
        VStack(alignment:.leading,spacing: 10){
            HStack{
                AsyncImage(url: self.profile.AvatarURL, content: { img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:80,height:80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 5))
                    
                    
                }, placeholder: {
                    ProgressView()
                        .frame(width:80,height:80)
                })
                
                VStack(alignment:.leading,spacing: 5){
                    HStack{
                        Text(self.profile.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if self.isFriend{
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text(self.profile.email)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .bold()
                }
                .padding(.top,20)
                .padding(.vertical)
                
                Spacer()
            }
            
            Text("About Me")
                .font(.headline)
                .bold()
                .padding(.top)
                .foregroundColor(.white)
            
            Text("Hi,i am jacksontmm. If you want to contact with me, please add me here!")
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .font(.body)
                .bold()
                .padding(.vertical)
                .foregroundColor(.gray)
            
            
            if self.isFriend {
                    Button(action: {
                        
                    }){
                        HStack{
                            Spacer()
                            Text("Chat")
                                .foregroundColor(.white)
                                .bold()
                            Spacer()
                        }
                        .padding()
                        .background(.green)
                        .cornerRadius(10)
                    }
                
                    Button(action: {
                        Task{
                            await deleteFriend()
                        }
                    }){
                        HStack{
                            Spacer()
                            Text("Delete Friend")
                                .foregroundColor(.white)
                                .bold()
                            Spacer()
                        }
                        .padding()
                        .background(.red)
                        .cornerRadius(10)
                    }
            }else {
                Button(action: {
                    Task{
                        await addFriend()
                    }
                }){
                    HStack{
                        Spacer()
                        Text("Add Me")
                            .foregroundColor(.white)
                            .bold()
                        Spacer()
                    }
                    .padding()
                    .background(.blue)
                    .cornerRadius(10)
                }
            
            }
        
        }
        
    }
    
    

    private func addFriend() async{
        let req = AddFriendReq(user_id: self.profile.id)
        let resp = await ChatAppService.shared.AddFriend(req: req)
        
        switch resp {
        case .success(let data):
            print(data.code)
            DispatchQueue.main.async {
                self.isFriend = true
            }
            break
        case .failure(let err):
            BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            break
        }
    }
    
    private func deleteFriend() async{
        let req = DeleteFriendReq(user_id: self.profile.id)
        let resp = await ChatAppService.shared.DeleteFriend(req: req)
        
        switch resp {
        case .success(let data):
            print(data.code)
            DispatchQueue.main.async {
                self.isFriend = false
            }
            break
        case .failure(let err):
            BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            break
        }
    }
    
    private func blockFriend(){}
}

//struct UserContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserContentView(profile: UserProfile(id: 1, uuid: UUID().uuidString, name: "Jacksontmm", email: "Admin@admin.com", avatar: "/default.jpg", cover: "/cover.jpg"), isFriend: .constant(false))
//    }
//}
