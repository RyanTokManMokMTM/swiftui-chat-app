//
//  GroupProfileEditView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 24/4/2023.
//

import SwiftUI
import PhotosUI
struct GroupProfileEditView: View {
    var info : FullGroupInfo
    let groupName : String
    @State private var name : String = ""
    @FocusState private var isFocus : Bool
    @State private var isSelected : Bool = false
    @State private var selectedItems : PhotosPickerItem? = nil
    var body: some View {
        List{
            HStack{
                Spacer()
                AsyncImage(url: info.AvatarURL, content: { img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:100,height:100)
                        .clipShape(Circle())
                        .overlay(alignment:.bottomTrailing) {
                            Menu(content: {
                                Button(action: {
                                    withAnimation{
                                        self.isSelected = true
                                    }
                                }){
                                    Text("selected from album")
                                }
                            }, label: {
                                Image(systemName: "camera")
                                    .imageScale(.small)
                                    .padding(5)
                                    .foregroundColor(.black)
                                    .background(BlurView(style: .systemChromeMaterialLight).clipShape(Circle()))
                            })
        
                        }
                }, placeholder: {
                    ProgressView()
                })
                Spacer()
            }

            
            Section("Group Name"){
                TextField("Enter a group name", text: $name)
                    .submitLabel(.done)
                    .focused($isFocus)
            }
        }
        .listStyle(.plain)
        .onAppear{
            self.name = groupName
        }
        .photosPicker(isPresented: $isSelected, selection: $selectedItems, photoLibrary: .shared())
    }
}

struct GroupProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        GroupProfileEditView(info: FullGroupInfo(id: 1, uuid: UUID().uuidString, name: "test_group", avatar: "/default7.jpg", members: 1, created_at: UInt(Date.timeIntervalBetween1970AndReferenceDate), is_joined: true, is_owner: true), groupName: "test_group")
    }
}
