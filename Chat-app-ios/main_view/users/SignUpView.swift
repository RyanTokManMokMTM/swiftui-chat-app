//
//  SignUpView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 17/2/2023.
//

import SwiftUI

struct SignUpView: View {
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
//                .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
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
                        
                        
                        HStack(spacing:2){
                            Image(systemName: isCheck ? "checkmark.circle.fill":  "circle")
                                .foregroundColor(isCheck ? .blue : .gray)
                                .bold()
                                .onTapGesture {
                                    DispatchQueue.main.async {
                                        self.isCheck = !self.isCheck
                                    }
                                }
                            Text("Read and agree our service policy.")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .padding(5)

                        }
                        
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
        
//        .background()
//        .padding(.top,UIScreen.main.bounds.height / 10)
    }
    
    private func isAllowToLogin() -> Bool {
        return !self.email.isEmpty && !self.password.isEmpty && !self.userName.isEmpty && !self.comfirmPassword.isEmpty
    }
    
    private func sendSignUpRequest() async {
        let req = SignUpReq(email: self.email, name: self.userName, password: self.password)
        let resp = await ChatAppService.shared.UserSignUp(req: req)
        switch resp {
        case .success(let data):
//            withAnimation{
//                self.isSignUp = false
//            }
            print(data)
            break
        case .failure(let err):
            print(err)
            break
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(isSignUp: .constant(false))
    }
}
