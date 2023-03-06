//
//  Util.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 5/3/2023.
//

import Foundation

class Util {
    static let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        return dateFormatter
    }()
    
    static let Formatter: DateFormatter = {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return Formatter
    }()

}
