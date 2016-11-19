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


extension Double {
    
    private func formatType(form: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        dateFormatter.dateFormat = form
        return dateFormatter
    }
    
    var dateFull: NSDate {
        return NSDate(timeIntervalSinceReferenceDate: Double(self))
    }
    var toHour: String {
        return formatType(form: "HH:mm").string(from: dateFull as Date)
    }
    
    var toDay: String {
        return formatType(form: "MM/dd/yyyy").string(from: dateFull as Date)
    }
    
    var formatMillisecondsToCoherentTime: String {
        
        let time = (Date.timeIntervalSinceReferenceDate - self)/60

        switch time {
            case 0..<60 :
                return "\(Int(time)) min ago"
            case 60..<1440 :
                return "\(Int(time/60)) hours ago"
            case 1440..<10080 :
                return "\(Int(time/60))) days ago"
            case 10080..<40320 :
                return "\(Int(time/60/24/7)) weeks ago"
            default:
                return self.toDay
        }
    }
}
