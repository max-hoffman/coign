//
//  File.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/5/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation

extension DateFormatter {
    convenience init(dateStyle: DateFormatter.Style) {
        self.init()
        self.dateStyle = dateStyle
    }
}

extension Date {
    struct Formatter {
        static let shortDate = DateFormatter(dateStyle: .short)
    }
    var shortDate: String {
        return Formatter.shortDate.string(from: self)
    }
}
