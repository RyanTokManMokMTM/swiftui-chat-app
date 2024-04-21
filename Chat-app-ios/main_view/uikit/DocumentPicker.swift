//
//  DocumentPicker.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 18/3/2023.
//

import Foundation
import SwiftUI
import UIKit
import MobileCoreServices

struct DocumentPicker : UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.data,.text,.pdf,.audio,.video])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        
    }
    
    class Coordinator : NSObject, UIDocumentPickerDelegate{
        var parent : DocumentPicker
        init(parent : DocumentPicker){
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        }
    }
}

