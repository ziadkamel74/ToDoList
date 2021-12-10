//
//  String+Trimmed.swift
//  Rabel
//
//  Created by Ziad on 03/11/2021.
//

import Foundation

extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
