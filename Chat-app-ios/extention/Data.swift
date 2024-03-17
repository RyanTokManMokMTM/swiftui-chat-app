//
//  Data.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 6/3/2023.
//

import Foundation
import UniformTypeIdentifiers


public extension Data {
    var fileExtension: String {
        var values = [UInt8](repeating:0, count:1)
        self.copyBytes(to: &values, count: 1)
       
        let ext: String
        switch (values[0]) {
        case 0xFF:
            ext = "jpeg"
        case 0x89:
            ext = "png"
        case 0x47:
            ext = "gif"
        case 0x49, 0x4D :
            ext = "tiff"
        case 0x00:
            return "mp4"
        case 0x6D:
            return "mov"
        case 0x30:
            return "wav"
        default:
            ext = "png"
        }
        return ext
    }
    
  
}

func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
  let data = NSMutableData()

  data.appendString("--\(boundary)\r\n")
  data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
  data.appendString("Content-Type: \(mimeType)\r\n\r\n")
  data.append(fileData)
  data.appendString("\r\n")

  return data as Data
}

extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}

