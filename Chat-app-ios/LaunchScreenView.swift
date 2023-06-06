//
//  LaunchScreenView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 25/5/2023.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimiate : Bool = false
    @Binding var isEnd : Bool
    var body: some View {
        ZStack{
            ZStack{
                Color("bg")
                Image("logo")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 85, height: 85)
//                    .frame(width: isAnimiate ? nil : 85, height:isAnimiate ? nil : 85)
//                    .scaleEffect(isAnimiate ? 1 : 3 )
//                    .frame(width: UIScreen.main.bounds.width)
//                    .opacity(self.isEnd ? 0 : 1)
              
            }.edgesIgnoringSafeArea(.all)
        }
        .onAppear{
            start()
        }

        
    }
    
    private func start(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
            withAnimation(.easeOut(duration: 0.45)){
                self.isAnimiate = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeOut(duration: 0.35)){
                    self.isEnd = true
                }
            }
        }
    }
    
}

//struct LaunchScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        LaunchScreenView()
//    }
//}
