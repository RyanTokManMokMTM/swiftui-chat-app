//
//  Doc.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/4/2023.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
struct Doc : FileDocument {
    
    let url : URL?
    
    static var readableContentTypes : [UTType]{
        [.plainText,.pdf,.mp3,.audio]
    }
    static var writableContentTypes : [UTType] {
        [.plainText,.pdf,.data,.mp3,.audio]
    }
    init(url : URL?){
        self.url = url
    }
    
    init(configuration config : ReadConfiguration) throws {
        self.url = nil
    }
    
    func fileWrapper(configuration config : WriteConfiguration) throws -> FileWrapper {
        return try! FileWrapper(url: self.url!)
    }
}
