//
//  Task.swift
//  TodoList
//
//  Created by KhoaLA8 on 18/6/24.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct Task: Codable {
    
    var id = ""
    var title = ""
    var userId = ""
    var status = "Not Started"
    
    @ServerTimestamp var createdDate = Date()

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case userId
        case status
        case createdDate
    }
}
