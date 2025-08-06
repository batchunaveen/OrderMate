//
//  PDFFile.swift
//  OrderMate
//
//  Created by Naveen on 8/4/25.
//

//MARK: - PDFFile
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct PDFFile: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }

    var url: URL

    init(url: URL) {
        self.url = url
    }

    init(configuration: ReadConfiguration) throws {
        fatalError("Not supported")
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: url)
    }
}
