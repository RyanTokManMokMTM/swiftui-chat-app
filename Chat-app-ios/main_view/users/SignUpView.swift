//
//  SignUpView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 17/2/2023.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var hub = BenHubState.shared
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var comfirmPassword : String = ""
    @State private var userName : String = ""
    @State private var isCheck = false
    @Binding var isSignUp : Bool
    var body: some View {
        ZStack{
            Color.white.frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
            
            VStack(alignment:.leading){
                HStack{
                    Button(action:{
                        withAnimation{
                            self.isSignUp.toggle()
                        }
                    }){
                        Image(systemName: "arrow.left")
                            .imageScale(.large)
                            .foregroundColor(.black)
                    }
                    
                }
                .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
                .padding(.horizontal)
                
                VStack{
                    HStack{
                        Text("Create a new account")
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
                            TextField("Name", text: $userName)
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
                        
                        HStack{
                            SecureField("Comfirm Password", text: $comfirmPassword)
                                .padding()
                        }
                        .padding(.vertical,5)
            //            .padding(.horizontal,5)
                        .background(BlurView(style:.systemMaterial).cornerRadius(25))
        //                .padding(.horizontal)
                        
                        
//                        HStack(spacing:2){
//                            Image(systemName: isCheck ? "checkmark.circle.fill":  "circle")
//                                .foregroundColor(isCheck ? .blue : .gray)
//                                .bold()
//                                .onTapGesture {
//                                    DispatchQueue.main.async {
//                                        self.isCheck = !self.isCheck
//                                    }
//                                }
//                            Text("Read and agree our service policy.")
//                                .foregroundColor(.gray)
//                                .font(.subheadline)
//                                .padding(5)
//
//                        }
                        
                    }
                    .padding(.horizontal)

                    Button(action: {
                        Task.init{
                            await self.sendSignUpRequest()
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
        //            Spacer()
                    Spacer()
                }
                .padding(.vertical,80)
            }
            

            
//            Spacer()
        
        }
//        .wait(isLoading: $hub.isWaiting){
//            BenHubLoadingView(message: hub.message)
//        }
//        .alert(isAlert: $hub.isPresented){
//            BenHubAlertView(message: hub.message, sysImg: hub.sysImg)
//        }

    }
    
    private func isAllowToLogin() -> Bool {
        return !self.email.isEmpty && !self.password.isEmpty && !self.userName.isEmpty && !self.comfirmPassword.isEmpty
    }
    
    @MainActor
    private func sendSignUpRequest() async {
        hub.SetWait(message: "Registering your account...")
        let req = SignUpReq(email: self.email, name: self.userName, password: self.password)
        let resp = await ChatAppService.shared.UserSignUp(req: req)
        
        hub.isWaiting = false
        switch resp {
        case .success(_):
            hub.AlertMessage(sysImg: "checkmark", message: "succeed.")
            self.email.removeAll()
            self.password.removeAll()
            self.comfirmPassword.removeAll()
            self.userName.removeAll()
            self.isSignUp = false
            break
        case .failure(let err):
            hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            break
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(isSignUp: .constant(false))
    }
}
