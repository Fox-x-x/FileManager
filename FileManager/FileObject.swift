//
//  FileObject.swift
//  FileManager
//
//  Created by Pavel Yurkov on 05.04.2021.
//

import Foundation

struct FileObject {
    var url: URL
    var name: String
    
    init(url: URL, name: String) {
        self.url = url
        self.name = name
    }
}
