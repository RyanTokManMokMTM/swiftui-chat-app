//
//  helper.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 29/4/2023.
//

import Foundation
import AVFoundation
import UIKit

func getThumbnailImage(forURL url : URL) -> UIImage? {
    let asset : AVAsset = AVAsset(url: url)
    let imageGen = AVAssetImageGenerator(asset: asset)
    
    do {
        let thum = try imageGen.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
        return UIImage(cgImage: thum)
    } catch {
        print(error.localizedDescription)
    }
    return nil
}

func getLocalThumbnailImage(forURL url : URL) -> UIImage? {
    let asset : AVAsset = AVAsset(url: url)
    let imageGen = AVAssetImageGenerator(asset: asset)
    
    do {
        let thum = try imageGen.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
        return UIImage(cgImage: thum)
    } catch {
        print(error.localizedDescription)
    }
    return nil
}
