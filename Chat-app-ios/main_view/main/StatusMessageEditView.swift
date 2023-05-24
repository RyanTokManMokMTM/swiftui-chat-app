//
//  StatusMessageEditView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 23/4/2023.
//

import SwiftUI

struct StatusMessageEditView: View {
    @EnvironmentObject private var userModel : UserViewModel
    @Binding var isEditStatusMsg : Bool
    let originalMsg : String
    
    @StateObject private var hub = BenHubState.shared
    @State private var isEdited = false
    @State private var msg : String = ""
    var body: some View {
        VStack{
            
            TextField(text: $msg) {
                Text("Enter status message")
                    .foregroundColor(.gray)
            }
            .foregroundColor(.white)
            .padding(.horizontal)
            .font(.system(size:30))
            
        }
        .frame(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
        .edgesIgnoringSafeArea(.all)
        .background(
            AsyncImage(url: self.userModel.profile!.CoverURL, content: { img in
                img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)

            }, placeholder: {
                ProgressView()
            })
            .overlay{
                BlurView().edgesIgnoringSafeArea(.all)
            }

        )
        .overlay(alignment:.top){
            HStack{
                Button(action:{
                    withAnimation{
                        self.isEditStatusMsg = false
                    }
                }){
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                
                Spacer()
                Text("\(self.msg.count) / 50")
                    .foregroundColor(.gray)
                Spacer()
                Button(action:{
                    Task {
                        await self.updateStateusMessage()
                    }
                }){
                    Text("Save")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(self.isEdited ? .white : .gray)
                }
                .disabled(!self.isEdited)
            }
            .padding(.horizontal)
            .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
        }
        .onAppear{
            self.msg = originalMsg
        }
        .onChange(of: self.msg){ text in
            if text != originalMsg && !self.isEdited {
                isEdited = true
            }
            self.msg = String(self.msg.prefix(50))
        }
//        .wait(isLoading: $hub.isWaiting){
//            BenHubLoadingView(message: hub.message)
//        }
//        .alert(isAlert: $hub.isPresented){
//            BenHubAlertView(message: hub.message, sysImg: hub.sysImg)
//        }
    }
    
    private func check(msg : String) -> Bool {
        return msg.count > 50
    }
    
    private func updateStateusMessage() async {
        hub.SetWait(message: "Updating...")
        let req = UpdateStatusReq(status: self.msg)
        let resp = await ChatAppService.shared.UpdateStatusMessage(req: req)
        
        DispatchQueue.main.async {
            hub.isWaiting = false
            switch resp{
            case .success(_):
                hub.AlertMessage(sysImg: "check", message: "Updated.")
                self.userModel.profile!.status = self.msg
                withAnimation {
                    self.isEditStatusMsg = false
                }
            case .failure(let err):
                hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
                print(err.localizedDescription)
            }
        }
      
    }
}
