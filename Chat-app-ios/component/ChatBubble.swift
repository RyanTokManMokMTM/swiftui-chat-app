//
//  ChatBubble.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 21/2/2023.
//

import SwiftUI

struct TextBubbleShape: Shape {
    enum Direction {
        case sender
        case receiver
    }
    let direction : Direction
    func path(in rect: CGRect) -> Path {
        return direction == .sender ? getSenderBubble(in: rect) : getReceiverBubble(in: rect)
    }
    
    private func getReceiverBubble(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        return Path { p in
            p.move(to: CGPoint(x: 25, y: height))
                        p.addLine(to: CGPoint(x: width - 20, y: height))
                        p.addCurve(to: CGPoint(x: width, y: height - 20),
                                   control1: CGPoint(x: width - 8, y: height),
                                   control2: CGPoint(x: width, y: height - 8))
                        p.addLine(to: CGPoint(x: width, y: 20))
                        p.addCurve(to: CGPoint(x: width - 20, y: 0),
                                   control1: CGPoint(x: width, y: 8),
                                   control2: CGPoint(x: width - 8, y: 0))
                        p.addLine(to: CGPoint(x: 21, y: 0))
                        p.addCurve(to: CGPoint(x: 4, y: 20),
                                   control1: CGPoint(x: 12, y: 0),
                                   control2: CGPoint(x: 4, y: 8))
                        p.addLine(to: CGPoint(x: 4, y: height - 11))
                        p.addCurve(to: CGPoint(x: 0, y: height),
                                   control1: CGPoint(x: 4, y: height - 1),
                                   control2: CGPoint(x: 0, y: height))
                        p.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
                        p.addCurve(to: CGPoint(x: 11.0, y: height - 4.0),
                                   control1: CGPoint(x: 4.0, y: height + 0.5),
                                   control2: CGPoint(x: 8, y: height - 1))
                        p.addCurve(to: CGPoint(x: 25, y: height),
                                   control1: CGPoint(x: 16, y: height),
                                   control2: CGPoint(x: 20, y: height))
                        
        }
    }
    
    private func getSenderBubble(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        return Path { p in
            p.move(to: CGPoint(x: 25, y: height))
                        p.addLine(to: CGPoint(x:  20, y: height))
                        p.addCurve(to: CGPoint(x: 0, y: height - 20),
                                   control1: CGPoint(x: 8, y: height),
                                   control2: CGPoint(x: 0, y: height - 8))
                        p.addLine(to: CGPoint(x: 0, y: 20))
                        p.addCurve(to: CGPoint(x: 20, y: 0),
                                   control1: CGPoint(x: 0, y: 8),
                                   control2: CGPoint(x: 8, y: 0))
                        p.addLine(to: CGPoint(x: width - 21, y: 0))
                        p.addCurve(to: CGPoint(x: width - 4, y: 20),
                                   control1: CGPoint(x: width - 12, y: 0),
                                   control2: CGPoint(x: width - 4, y: 8))
                        p.addLine(to: CGPoint(x: width - 4, y: height - 11))
                        p.addCurve(to: CGPoint(x: width, y: height),
                                   control1: CGPoint(x: width - 4, y: height - 1),
                                   control2: CGPoint(x: width, y: height))
                        p.addLine(to: CGPoint(x: width + 0.05, y: height - 0.01))
                        p.addCurve(to: CGPoint(x: width - 11, y: height - 4),
                                   control1: CGPoint(x: width - 4, y: height + 0.5),
                                   control2: CGPoint(x: width - 8, y: height - 1))
                        p.addCurve(to: CGPoint(x: width - 25, y: height),
                                   control1: CGPoint(x: width - 16, y: height),
                                   control2: CGPoint(x: width - 20, y: height))

                        
        }
    }
}

struct ChatBubble<Content> : View where Content : View {
    let chatUser : ContentInfo
    let direction : TextBubbleShape.Direction
    let content :()->Content
    let contentType : Int
    init(direction : TextBubbleShape.Direction,chatUser : ContentInfo,contentType : Int,@ViewBuilder content : @escaping ()->Content){
        self.direction = direction
        self.content = content
        self.chatUser = chatUser
        self.contentType = contentType
    }
    
    var body: some View {
        HStack{
            if direction == .sender {
                Spacer()
            }
            HStack(alignment:.bottom){
                if direction == .receiver {
                    AsyncImage(url: chatUser.AvatarURL, content: { img in
                       img
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width:35,height: 35)
                            .clipShape(Circle())
                        
                    }, placeholder: {
                        ProgressView()
                            .frame(width:35,height: 35)
                    })
                    
                }
                if contentType == 1 {
                    content()
                        .clipShape(TextBubbleShape(direction: direction))
                }else {
                    content()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                
            }
            if direction == .receiver {
                Spacer()
            }
        }
        .padding((direction == .receiver) ? .leading : .trailing,20)
        .padding([.top,.bottom],5)
        .padding((direction == .sender) ? .leading : .trailing,70)
    }
}
