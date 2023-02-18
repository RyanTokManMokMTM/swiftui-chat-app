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
    var body: some View {
        //         NavigationSplitView(
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
                        TextField("ID/Email", text: $email)
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
                    print("login")
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
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
