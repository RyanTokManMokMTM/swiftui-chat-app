//
//  EditView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 22/4/2023.
//

import SwiftUI

enum EditType : String {
    case name = "Display Name"
    case status = "Status Message"
}

struct EditView: View {
    
    @EnvironmentObject private var userModel : UserViewModel
    
    let data : String
    let placeHolder : String
    let editType : EditType
    @StateObject private var hub = BenHubState.shared
    @State private var text : String = ""
    @FocusState private var isFocus : Bool
    @State private var isEdit : Bool = false
    @Environment(\.presentationMode) var present
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            VStack(alignment:.leading){
                
                HStack{
                    Text(editType.rawValue)
                        .bold()
                    Spacer()
                    
                    Text("\(text.count)/\(editType == .status ? 50 : 30)")
                        .foregroundColor(.gray)
                }

                    .padding(.vertical,5)
                
                
                TextField(placeHolder, text: $text)
                    .submitLabel(.done)
                    .focused($isFocus)
                
                
                Divider()
            }
            .padding()
        }
//        .wait(isLoading: $hub.isWaiting){
//            BenHubLoadingView(message: hub.message)
//        }
//        .alert(isAlert: $hub.isPresented){
//            BenHubAlertView(message: hub.message, sysImg: hub.sysImg)
//        }
        .onChange(of: text){ _ in
            if text != data && !self.isEdit {
                isEdit = true
            }
            
            if editType == .status {
                self.text = String(self.text.prefix(50))
            }else {
                self.text = String(self.text.prefix(32))
            }
        }
        .onAppear{
            self.text = data
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                Button(action:{
                    switch editType {
                    case .name:
                        Task {
                            await self.updateUserName()
                        }
                    case .status:
                        Task{
                            await self.updateStausMesasge()
                        }
                    }
                }){
                    Text("save")
                        .bold()
                        
                }

                    
            }

        }
    }

    
    @MainActor
    private func updateUserName() async {
        hub.SetWait(message: "Updating...")
        let req = UpdateUserInfoReq(name: self.text)
        let resp = await ChatAppService.shared.UpdateUserInfo(req: req)
       
        hub.isWaiting = false
        switch resp {
        case .success(_):
            hub.AlertMessage(sysImg: "check", message: "Updated.")
            self.userModel.profile!.name = self.text
            withAnimation{
                self.present.wrappedValue.dismiss()
            }
        case .failure(let err):
            hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
        }
    }
    private func updateStausMesasge() async {
        hub.SetWait(message: "Updating...")
        let req = UpdateStatusReq(status: self.text)
        let resp = await ChatAppService.shared.UpdateStatusMessage(req: req)
       
        hub.isWaiting = false
        switch resp {
        case .success(_):
            hub.AlertMessage(sysImg: "check", message: "Updated.")
            self.userModel.profile!.status = self.text
            withAnimation{
                self.present.wrappedValue.dismiss()
            }
        case .failure(let err):
            hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
        }
    }
}

