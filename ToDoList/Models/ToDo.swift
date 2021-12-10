//
//  ToDo.swift
//  ToDoList
//
//  Created by Ziad on 25/11/2021.
//

import Foundation

struct ToDo {
    let id: String
    let title: String
    let date: Date
    let location: Location?
    let activeReminder: Bool
    
    func asDict() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["id"] = id
        dict["title"] = title
        dict["date"] = String.getString(from: date)
        dict["activeReminder"] = activeReminder
        dict["latitude"] = location?.latitude
        dict["longitude"] = location?.longitude
        return dict
    }
}

struct Location {
    let latitude: Double
    let longitude: Double
}
