//
//  GroupCallingView.swift
//  Chat-app-ios
//
//  Created by TOK MAN MOK on 9/3/2024.
//

import SwiftUI
struct TestCallingData : Identifiable {
    let id = UUID().uuidString
    let name : String
    let avatar : String
}

let dummyDataCalls = [
    TestCallingData(name: "test1", avatar: "test1"),
    TestCallingData(name: "test2", avatar: "test2"),
    TestCallingData(name: "test3", avatar: "test3"),
    TestCallingData(name: "test4", avatar: "test4"),
    TestCallingData(name: "test5", avatar: "test5"),
    TestCallingData(name: "test6", avatar: "test6"),
    TestCallingData(name: "test7", avatar: "test7"),
    TestCallingData(name: "test8", avatar: "test8"),
    TestCallingData(name: "test9", avatar: "test9"),
    TestCallingData(name: "test10", avatar: "test10"),
    TestCallingData(name: "test11", avatar: "test11"),
    TestCallingData(name: "test12", avatar: "test12"),
    TestCallingData(name: "test13", avatar: "test13"),
    TestCallingData(name: "test14", avatar: "test14"),
    TestCallingData(name: "test15", avatar: "test15"),
    TestCallingData(name: "test16", avatar: "test16"),
    
]

struct GroupCallingView: View {
    //One prodcuer
    //Many Consumer
    @EnvironmentObject private var producerVM : SFUProdcuerViewModel
    let columns = Array(repeating: GridItem(spacing: 5, alignment: .center), count: 4)
   
    var body: some View {
        VStack{
            Text("Producer: Connection status : \(self.producerVM.callState.rawValue)")
            Text("connectionStatus : \(self.producerVM.connectionStatus.rawValue)")
            Text("isSetLoaclSDP : \(self.producerVM.isSetLoaclSDP.description)")
            Text("isSetRemoteSDP : \(self.producerVM.isSetRemoteSDP.description)")
            Text("localCanindate : \(self.producerVM.localCanindate)")
            Text("remoteCanindate : \(self.producerVM.remoteCanindate)")
//            LazyVGrid(columns: columns, spacing: 10) {
//                ForEach(dummyDataCalls, id: \.id) { user in
//                    testView(item: user)
//                }
//            }
//            
            Button(action: {
                withAnimation{
                    DispatchQueue.main.async { //TODO: Send disconnected signal and Disconnect and reset all RTC
                        self.producerVM.sendDisconnect()
                        self.producerVM.DisConnect()
                        self.producerVM.isIncomingCall = false
                        
                    }
                }
            }){
                Text("Return")
                    .foregroundColor(.red)
                    .background(Color.blue.cornerRadius(10))
            }
        }
        .onChange(of: self.producerVM.callState){ state in
                            print("State Changed : \(state)")
//                            if state == .Ended { //TODO: the connection is disconnected -> Reset all the and disconnect
//                                DispatchQueue.main.async {
//                                    self.producerVM.isIncomingCall = false
//                                    self.producerVM.DisConnect()
//                                }
//                            }
                        }

    }
    
    @ViewBuilder
    private func testView(item : TestCallingData) -> some View {
        VStack(spacing:0){
            Image(item.avatar)
                .resizable()
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                .frame(width: 45,height: 45)
                .clipShape(Circle())
                .padding(.top,10)
            
            Text(item.name)
                .font(.system(size: 12))
                .bold()
                .padding(.vertical,5)
        }
        .frame(width: 100,height: 100)
        .background(BlurView().clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners])))
//        .clipShape(CustomConer(coners: [.allCorners]))
    }
}
//
//#Preview {
//    GroupCallingView()
//}
