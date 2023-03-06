//
//  CustomConer.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 6/3/2023.
//

import SwiftUI

struct CustomConer : Shape {
    var width :CGFloat = 30
    var height :CGFloat = 30
    var coners : UIRectCorner

    func path(in rect: CGRect) -> Path {
        //set coner and coner radius
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: coners, cornerRadii: CGSize(width: width, height: height))
        return Path(path.cgPath)
    }
}
