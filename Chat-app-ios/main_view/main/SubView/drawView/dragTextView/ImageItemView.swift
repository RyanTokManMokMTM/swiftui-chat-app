//
//  ImageItemView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/9/2023.
//

import SwiftUI

struct ImageItemView: View {
    var box : StorySubItem
    var center : CGFloat
    var heigh : CGFloat
    var proxyFrame : CGSize
    
    @Binding var isInTransh : Bool
    @Binding var dragginItemId : String
    @Binding var isDragging : Bool
    @Binding var isLeadingAlignment : Bool
    @Binding var isTralingAlignment : Bool
    @Binding var isTopAlignment : Bool
    @Binding var isBottomAlignment : Bool
    @Binding var isHorizontalAlignment : Bool
    @Binding var isVerticalAlignment : Bool

    
    @State private var currentItemSize : CGSize = .zero
    @EnvironmentObject private var drawVM : DrawScreenViewModel
    var body: some View {
        Image(uiImage: UIImage(data: box.imageData!)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius( box.isConer ? 10 : 0)
            .background{
                GeometryReader{ proxy  -> Color in
                    DispatchQueue.main.async {
                        self.currentItemSize = proxy.size
                        let newWidthAfterRotate1 = self.currentItemSize.height * sin(box.angle.radians)
                        let newWidthAfterRotate2 = self.currentItemSize.width * cos(box.angle.radians)
                        let newHeightAfterRotate1 = self.currentItemSize.height * cos(box.angle.radians)
                        let newHeightAfterRotate2 = self.currentItemSize.width * sin(box.angle.radians)
                        self.currentItemSize.width = abs(newWidthAfterRotate1) + abs(newWidthAfterRotate2)
                        self.currentItemSize.height = abs(newHeightAfterRotate1) + abs(newHeightAfterRotate2)
                        self.currentItemSize.width *= (box.scaleFactor + box.lastScaleFactor) //new width after scale
                        self.currentItemSize.height *= (box.scaleFactor + box.lastScaleFactor) //new heigh after scale
                        //https://i.stack.imgur.com/C6NVo.png
                    }
                    return Color.clear
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.22, alignment: .center)
            .rotationEffect( box.angle)
            .scaleEffect( box.scaleFactor +  box.lastScaleFactor )
            .offset( box.offset)
//            .clipShape(box.itemShape)
            .onTapGesture {
//                withAnimation{
                    self.drawVM.storySubItems[getTextBoxIndex(box: box)].isConer.toggle()
                    self.drawVM.reorderTextBoxs(itemToTop: box)
//                }
            }
            .gesture(
                MagnificationGesture().onChanged{v in
                    self.drawVM.storySubItems[getTextBoxIndex(box: box)].scaleFactor = v.magnitude - 1
                }.onEnded{ v in
                    self.drawVM.storySubItems[getTextBoxIndex(box: box)].lastScaleFactor +=  self.drawVM.storySubItems[getTextBoxIndex(box: box)].scaleFactor
                    
                    self.drawVM.storySubItems[getTextBoxIndex(box: box)].scaleFactor = 0
                
                }).simultaneousGesture(DragGesture()
                    .onChanged( { v in
                        if !self.isDragging  {
                            self.isDragging = true
                            self.dragginItemId = box.id
                        }
                        let last = box.lastOffset
                        var new = last

                        new.width += v.translation.width
                        new.height += v.translation.height

                        let leading = leadingAlignmentChecking(proxyFrame: proxyFrame, newLocation: new)
                        let traling = tralingAlignmentChecking(proxyFrame: proxyFrame, newLocation: leading)
                        let topLocation = topAlignmentChecking(proxyFrame: proxyFrame, newLocation: traling)
                        let bottomLocation = bottomAlignmentChecking(proxyFrame: proxyFrame, newLocation: topLocation)
                        let vertical = verticalAlignmentChecking(proxyFrame: proxyFrame, newLocation: bottomLocation)
                        self.drawVM.storySubItems[getTextBoxIndex(box: box)].offset = horizontalAlignmentChecking(proxyFrame: proxyFrame, newLocation: vertical)


                        let left = center - 25
                        let right = center + 25
                        let top = heigh - 50
                        let bottom = heigh - 10
                        let location = v.location
                        if location.y >= top && location.y  <= bottom && location.x >= left && location.x <= right {
                            withAnimation{
                                self.isInTransh = true
                            }
                        } else {
                            withAnimation{
                                self.isInTransh = false
                            }
                        }

                    })
                    .onEnded { v in
                        drawVM.storySubItems[getTextBoxIndex(box: box)].lastOffset = drawVM.storySubItems[getTextBoxIndex(box: box)].offset
                        self.isTopAlignment = false
                        self.isBottomAlignment = false
                        self.isLeadingAlignment = false
                        self.isTralingAlignment = false
                        self.isHorizontalAlignment = false
                        self.isVerticalAlignment = false
                        if self.isDragging {
                            self.isDragging = false
                            //                                }
                            self.dragginItemId = ""
                            if self.isInTransh {
                                self.drawVM.removeTextBox(textBox: box)
                                self.isInTransh = false
                            }
                        }
                    }

                )
                .simultaneousGesture(RotationGesture().onChanged{ v in
                    let cur = v.degrees
                    let last = self.drawVM.storySubItems[getTextBoxIndex(box: box)].lastAngle
                    
                    self.drawVM.storySubItems[getTextBoxIndex(box: box)].angle = .degrees(cur) + last
                }.onEnded{ v in
                    self.drawVM.storySubItems[getTextBoxIndex(box: box)].lastAngle = .degrees(v.degrees)
                })
    }
    
    private func getTextBoxIndex(box : StorySubItem) -> Int {
       let index = drawVM.storySubItems.firstIndex{$0.id == box.id} ?? 0
       return index
    }
    
    
    private func leadingAlignmentChecking(proxyFrame : CGSize,newLocation : CGSize) -> CGSize {
        var location = newLocation
        let startWidth = location.width - (self.currentItemSize.width / 2)
        let leadingAignment = -(proxyFrame.width / 2  - 10)
        
        if !isLeadingAlignment {
            if startWidth >= leadingAignment && startWidth <= leadingAignment + 3{
                withAnimation{
                    isLeadingAlignment = true
                }
            }
        }else {
            //TODO: To leave the alignment status
            if startWidth <= leadingAignment - 10 || startWidth >= leadingAignment + 10{
                withAnimation{
                    isLeadingAlignment = false
                }
            }
        }
        withAnimation{
            location.width = isLeadingAlignment ? leadingAignment + (self.currentItemSize.width / 2) : location.width
        }
        return location
    }
    
    private func tralingAlignmentChecking(proxyFrame : CGSize,newLocation : CGSize) -> CGSize{
        var location = newLocation
        let endWidth = location.width + (self.currentItemSize.width / 2)
        let tralingAignment = proxyFrame.width / 2  - 10
        
        if !isTralingAlignment {
            if endWidth >= tralingAignment && endWidth <= tralingAignment + 3{
                withAnimation{
                    isTralingAlignment = true
                }
            }
        }else {
            //TODO: To leave the alignment status
            if endWidth <= tralingAignment - 10 || endWidth >= tralingAignment + 10{
                withAnimation{
                    isTralingAlignment = false
                }
            }
        }
        withAnimation{
            location.width = isTralingAlignment ? tralingAignment - (self.currentItemSize.width / 2) : location.width
        }
        return location
    }
    
    private func topAlignmentChecking(proxyFrame : CGSize,newLocation : CGSize) -> CGSize{
        var location = newLocation
        let startHeight = location.height - (self.currentItemSize.height / 2)
        
        let topAignment = -((UIScreen.main.bounds.height / 1.22) / 2 - 50)
        if !isTopAlignment {
            if startHeight >= topAignment && startHeight <= topAignment + 3{
                withAnimation{
                    isTopAlignment = true
                }
            }
        }else {
            //TODO: To leave the alignment status
            if startHeight <= topAignment - 10 || startHeight >= topAignment + 10{
                withAnimation{
                    isTopAlignment = false
                }
            }
        }
        withAnimation{
            location.height = isTopAlignment ? topAignment + (self.currentItemSize.height / 2) : location.height
        }
        return location
    }
    
    private func bottomAlignmentChecking(proxyFrame : CGSize,newLocation : CGSize) -> CGSize{
        var location = newLocation
        let endHeight = location.height + (self.currentItemSize.height / 2)
        
        let bottomAignment = ((UIScreen.main.bounds.height / 1.22) / 2 - 50)
        if !isBottomAlignment {
            if endHeight >= bottomAignment && endHeight <= bottomAignment + 3{
                withAnimation{
                    isBottomAlignment = true
                }
            }
        }else {
            //TODO: To leave the alignment status
            if endHeight <= bottomAignment - 10 || endHeight >= bottomAignment + 10{
                withAnimation{
                    isBottomAlignment = false
                }
            }
        }
        withAnimation{
            location.height = isBottomAlignment ? bottomAignment - (self.currentItemSize.height / 2) : location.height
        }
        return location
    }
    
    private func verticalAlignmentChecking(proxyFrame : CGSize,newLocation : CGSize) -> CGSize{
        var location = newLocation


        if !isVerticalAlignment {
            if location.height >= 0 && location.height <=  3 {
                withAnimation{
                    isVerticalAlignment = true
                    
                }
            }
        }else {
            //TODO: To leave the alignment status
            if location.height <=  -10 || location.height >=  10{
                withAnimation{
                    isVerticalAlignment = false
                }
            }
        }
        withAnimation{
            location.height = isVerticalAlignment ? 0 : location.height
        }
        return location
    }
    
    private func horizontalAlignmentChecking(proxyFrame : CGSize,newLocation : CGSize) -> CGSize{
        var location = newLocation


        if !isHorizontalAlignment {
            if location.width >= 0 && location.width <=  3 {
                withAnimation{
                    isHorizontalAlignment = true
                }
            }
        }else {
            //TODO: To leave the alignment status
            if location.width <=  -10 || location.width >=  10{
                withAnimation{
                    isHorizontalAlignment = false
                }
            }
        }
        withAnimation(){
            location.width = isHorizontalAlignment ? 0 : location.width
        }
        return location
    }
}

