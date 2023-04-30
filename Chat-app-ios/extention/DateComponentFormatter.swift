//
//  DateComponentFormatter.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 28/4/2023.
//

import Foundation

extension DateComponentsFormatter {
    static let positional : DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute,.second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
}
