//
//  URL.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 21/3/2023.
//

import Foundation

extension URL {
    var filesize: Int? {
        let set = Set.init([URLResourceKey.fileSizeKey])
        var filesize: Int?
        do {
            let values = try self.resourceValues(forKeys: set)
            if let theFileSize = values.fileSize {
                filesize = theFileSize
            }
        }
        catch {
            print("Error: \(error)")
        }
        return filesize
    }
}
