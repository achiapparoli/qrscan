//
//  TaskModel.swift
//  QRScanner
//
//  Created by Alberto Chiapparoli on 02/05/23.
//

import Foundation


struct Folder: Identifiable, Codable {
    let id: UUID
    var name: String
    var colorName: String
    var tasks: [Task]
}

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var folder: Folder?
}

