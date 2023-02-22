//
//  Date.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 19/2/2023.
//

import SwiftUI


extension Date{
    
    func dateDescriptiveString(dataStyle : DateFormatter.Style = .short) -> String {
        //self = current class date
        let formatter = DateFormatter()
        formatter.dateStyle = dataStyle
        let dayBetween = daysBetween(date: Date())
        
        if dayBetween == 0{
            return "今天"
        } else if dayBetween == 1 {
            return "昨天"
        }else if dayBetween < 5 {
            let weekDay = Calendar.current.component(.weekday, from: self) - 1
            return formatter.weekdaySymbols[weekDay]
        }
        return formatter.string(from: self)
        
    }
    
    func sendTimeString(dataStyle : DateFormatter.Style = .short) -> String {
        //self = current class date
        let formatter = DateFormatter()
        formatter.dateStyle = dataStyle
        let dayBetween = daysBetween(date: Date())
        
        if dayBetween == 0{
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: self)
        } else if dayBetween == 1 {
            formatter.dateFormat = "HH:mm"
            return "昨天" + formatter.string(from: self)
        }else if dayBetween < 5 {
            formatter.dateFormat = "HH:mm"
            let weekDay = Calendar.current.component(.weekday, from: self) - 1
            return formatter.weekdaySymbols[weekDay] + formatter.string(from: self)
        }
        
        formatter.dateFormat = "yy/M/d HH:mm a"
        return formatter.string(from: self)
        
    }
    
    func daysBetween(date : Date) -> Int{
        let calender = Calendar.current
        let date1 = calender.startOfDay(for: self)
        let date2 = calender.startOfDay(for: date)
        if let dayByDay = calender.dateComponents([.day], from: date1, to: date2).day{
            return dayByDay
        }
        return 0
    }
}
