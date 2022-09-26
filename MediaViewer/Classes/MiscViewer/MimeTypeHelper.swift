//
//  MimeTypeHelper.swift
//  MediaViewer
//
//  Created by Omar on 20/04/2021.
//

import Foundation
import MobileCoreServices

extension String {
    var mimeType: String {
        URL(string: self)?.mimeType() ?? ""
    }
    var isImage: Bool {
        URL(string: self)?.isImage ?? false
    }
    var isAudio: Bool {
        URL(string: self)?.isAudio ?? false
    }
    var isVideo: Bool {
        URL(string: self)?.isVideo ?? false
    }
    var isPdf: Bool {
        (URL(string: self)?.isPdf ?? false)
    }
    var isDocument: Bool {
        isPdf || hasSuffix(".doc")
    }
}
extension URL {
    func mimeType() -> String {
         let pathExtension = self.pathExtension
         if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
             if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
             }
         }
         return "application/octet-stream"
    }
    var isImage: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
             return false
        }
        return UTTypeConformsTo(uti, kUTTypeImage)
    }
    var isAudio: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
              return false
        }
        return UTTypeConformsTo(uti, kUTTypeAudio)
    }
    var isVideo: Bool {
        let mimeType = self.mimeType()
        guard  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
               return false
        }
        return UTTypeConformsTo(uti, kUTTypeMovie)
    }
    var isPdf: Bool {
        let mimeType = self.mimeType()
        guard  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
               return false
        }
        return UTTypeConformsTo(uti, kUTTypePDF)
    }
 }
