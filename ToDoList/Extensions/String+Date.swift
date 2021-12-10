//
//  String+Date.swift
//  ToDoList
//
//  Created by Ziad on 25/11/2021.
//

import Foundation

extension String {
    static func getDate(from string: String, format: String = "MMM d, yyyy, h:mm a") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)!
    }
    
    static func getString(from date: Date, format: String = "MMM d, yyyy, h:mm a") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
