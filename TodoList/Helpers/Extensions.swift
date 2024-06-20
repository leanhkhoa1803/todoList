//
//  Extensions.swift
//  TodoList
//
//  Created by KhoaLA8 on 18/6/24.
//

import Foundation

extension Date {

    func stringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }

}
