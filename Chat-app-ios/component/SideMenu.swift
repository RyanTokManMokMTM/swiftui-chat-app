//
//  SideMenu.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 6/3/2023.
//

import SwiftUI

struct SideMenu<Content:View>: View {
    //    struct SideMenu : View {
    @EnvironmentObject private var userVM : UserViewModel
    @Binding var isShow : Bool
    @Binding var isShowProfile : Bool
    @State private var offset = 0.0
    @State private var isAnimated = false
    @State private var isEditProfile = false
    
    var content : () -> Content
    var body : some View {
        VStack{
            menu()
                .offset(x : self.isAnimated ? 0 : -UIScreen.main.bounds.width / 1.2)
                .transition(.move(edge: .leading))
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height,alignment:.leading)
        .edgesIgnoringSafeArea(.all)
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all).onTapGesture {
            withAnimation{
                self.isAnimated = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                withAnimation{
                    self.isShow.toggle()
                }
            }
        })
        .onAppear(){
            withAnimation{
                self.isAnimated = true
            }
        }
    }
    
    @ViewBuilder
    private func menu() -> some View {
        VStack(alignment:.leading,spacing:12){
            menuHeader()
                .padding(.horizontal,18)
                .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
                .padding(.top)
//                .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
//                .padding(.bottom)
            content()
            
        }
    
        .frame(width: UIScreen.main.bounds.width / 1.2, height: UIScreen.main.bounds.height,alignment:.leading)
        .background(Color.white.clipShape(CustomConer(coners: [.bottomRight,.topRight])))
        
        //        .gesture(
        //            DragGesture()
        //                .onChanged(self.onChage(value:))
        //                .onEnded(self.onEnded(value:))
        //        )
        //        .offset(x : -self.offset)
        
        
    }
    
    private func onChage(value : DragGesture.Value){
        print(value.translation.width)
        if value.translation.width > 0 {
            self.offset = value.translation.width
        }
    }
    
    private func onEnded(value : DragGesture.Value){
        if value.translation.width > 0 {
            withAnimation(){
                //                let cardHeight = UIScreen.main.bounds.height / 4
                //
                //                if value.translation.height > cardHeight / 2.8 {
                //                    self.previewModel.isShowPreview.toggle()
                //                }
                self.offset = 0
            }
        }
    }
    
    @ViewBuilder
    private func memuButton(imageName : String, title: String,action : @escaping ()->()) -> some View{
        Button(action:action){
            HStack(spacing:18){
                Image(systemName: imageName)
                    .imageScale(.large)
                    .font(.system(size: 15))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            .foregroundColor(.gray)
        }
    }
    
    @ViewBuilder
    private func menuHeader() -> some View {
        HStack{
            AsyncImage(url: self.userVM.profile?.AvatarURL ?? URL(string: "")!, content: { img in
                img
                    .resizable()
                    .aspectRatio( contentMode: .fill)
                    .frame(width: 40,height: 40)
                    .clipShape(Circle())
                
            }, placeholder: {
                ProgressView()
                    .frame(width: 40,height: 40)
            })
            
            Text(self.userVM.profile?.name ?? "UNKNOW")
                .font(.body)
                .bold()
            
            Spacer()
            
            Button(action: {
                withAnimation{
                    self.isShowProfile.toggle()
                }
            }, label: {
                Image(systemName: "gearshape")
                    .imageScale(.large)
            })
            .buttonStyle(.plain)

        }

    }
    
    
}

//struct SideMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        SideMenu(isShow: .constant(false))
//    }
//}
