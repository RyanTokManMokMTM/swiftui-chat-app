//
//  SignInView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 17/2/2023.
//

import SwiftUI

struct SignInView: View {
   
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var isCheck = false
    @State private var isSignUp = false
    @AppStorage("token") var token : String = ""
    @AppStorage("userName") var userEmail : String = ""
    @AppStorage("password") var userPassword : String = ""
    @AppStorage("userAvatar") var userAvatar : String = ""
    
    @Binding var isLogin : Bool
    @EnvironmentObject private var userViewModel : UserViewModel
    @EnvironmentObject private var UDM : UserDataModel
    @EnvironmentObject private var userStory : UserStoryViewModel
    @EnvironmentObject private var storyModel : StoryViewModel

    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Image(systemName: "bubble.right.fill")
                        .imageScale(.large)
                        .foregroundColor(.green)
                    Text("Hey!")
                        .bold()
                        .font(.title)
                        .padding(.vertical)
                }
                
                VStack(alignment:.leading,spacing:15){
                    HStack{
                        TextField("Email", text: $email)
                            .padding()
                    }
                    .padding(.vertical,5)
        //            .padding(.horizontal,5)
                    .background(BlurView(style: .systemMaterial).cornerRadius(25))
    //                .padding(.horizontal)
                    
                    
                    HStack{
                        SecureField("Password", text: $password)
                            .padding()
                    }
                    .padding(.vertical,5)
        //            .padding(.horizontal,5)
                    .background(BlurView(style:.systemMaterial).cornerRadius(25))
    //                .padding(.horizontal)
                    
                    
//                    HStack(spacing:2){
//                        Image(systemName: isCheck ? "checkmark.circle.fill":  "circle")
//                            .foregroundColor(isCheck ? .blue : .gray)
//                            .bold()
//                            .onTapGesture {
//                                DispatchQueue.main.async {
//                                    self.isCheck = !self.isCheck
//                                }
//                            }
//                        Text("Read and agree our service policy.")
//                            .foregroundColor(.gray)
//                            .font(.subheadline)
//                            .padding(5)
//
//                    }
                    
                }
                .padding(.horizontal)

                Button(action: {
                   
                    Task.init{
                        await self.sendSignInRequest()
                        //TODO: Update Token
                    
                    }
                }){
                    Group{
                        Image(systemName: "arrow.right")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .bold()
                    }
                    .frame(width: 85,height: 85)
                    .background(
                        isAllowToLogin() ? Color.blue.cornerRadius(50) : Color(uiColor: UIColor.systemGray5).cornerRadius(50))
                   
                }
                .disabled(!isAllowToLogin())
                .padding(.vertical,30)
                Spacer()
                
                HStack{
                    Text("Do not have an account?")
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        //TOOD: TO Sign Up Page
                        withAnimation{
                            self.isSignUp.toggle()
                        }
                    }){
                        Text("Sign up here")
                    }

                }
            }
            .padding(.top,UIScreen.main.bounds.height / 10)
            .padding(.bottom)
            if self.isSignUp{
                SignUpView(isSignUp: $isSignUp)
                    .animation(.default)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                    .zIndex(1)
            }
        }
        
    }
    
    private func isAllowToLogin() -> Bool {
        return !self.email.isEmpty && !self.password.isEmpty
    }
    
    private func sendSignInRequest() async{
        BenHubState.shared.SetWait(message: "Loading...")
        let req = SignInReq(email: self.email, password: self.password)
        let resp = await ChatAppService.shared.UserSignIn(req: req)
        DispatchQueue.main.async {
            switch resp {
            case .success(let data):
                BenHubState.shared.isWaiting = false
                withAnimation{
                    self.isLogin = false
                }
//                print(data.token)
                UserDefaults.standard.set(data.token, forKey: "token")
                self.userViewModel.profile = data.user_info
                
                if !UDM.fetchUserData(id: Int16(data.user_info.id)) {
                    UDM.addUserData(id: Int16(data.user_info.id), uuid: data.user_info.uuid, email: data.user_info.email, name: data.user_info.name, avatar: data.user_info.avatar)
                }
               
                BenHubState.shared.AlertMessage(sysImg: "checkmark", message: "login succeed!")
                Websocket.shared.connect() //TODO: connect to ws server
                Websocket.shared.userModel = userViewModel
//                Webcoket.shared.userData = UDM
                Task{
                    await self.userStory.GetUserStories()
                    await self.storyModel.GetActiveStory()
                }
                break
            case .failure(let err):
                BenHubState.shared.isWaiting = false
                BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
                print(err.localizedDescription)
                break
            }
        }
       
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(isLogin: .constant(false))
    }
}
