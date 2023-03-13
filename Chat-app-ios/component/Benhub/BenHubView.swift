//
//  BenHubView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 7/3/2023.
//

import SwiftUI

enum BenHubType {
    case Wait
    case Alert
}

struct BenHubView<Content : View>: View {
    let type : BenHubType
    @ViewBuilder var content : Content
    var body: some View {
        if type == .Wait {
            content
                .padding(.horizontal,12)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 5)
                )
        } else if type == .Alert {
            content
                .padding(.horizontal,12)
                .padding(16)
                .background(
                    Capsule()
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 5)
                )
            
        }
    }
}

extension View {
    func wait<Content : View>(isLoading : Binding<Bool>,@ViewBuilder content : ()->Content) -> some View{
        ZStack{
            self
            
            if isLoading.wrappedValue {
                Color.black.opacity(0.5).frame(maxWidth:.infinity,maxHeight: .infinity).edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                BenHubView(type:.Wait,content: content)
                    .zIndex(2)
                
            }
        }
    }
    
    func alert<Content : View>(isAlert : Binding<Bool>,@ViewBuilder content : () -> Content) -> some View{
        ZStack {
            self
            if isAlert.wrappedValue {
                Color.black.opacity(0.5).frame(maxWidth:.infinity,maxHeight: .infinity).edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                BenHubView(type:.Alert,content: content)
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                    .onAppear{
//                        print("???")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                            withAnimation{
                                isAlert.wrappedValue = false
                                print(isAlert.wrappedValue)
                            }
                        }
                    }
            }
        }
    }
}

struct BenHubLoadingView : View {
    let message : String
    var body: some View {
        VStack{
            ProgressView()
            
            Text(message)
                .font(.system(size: 14,weight:.semibold))
        }
        .padding(15)
      
    }
}

struct BenHubAlertView : View {
    let message : String
    let sysImg : String
    var body: some View {
        HStack(spacing:8){
            Image(systemName: sysImg)
                .imageScale(.medium)
            Text(message)
                .font(.system(size: 14,weight:.semibold))
        }
    }
}
