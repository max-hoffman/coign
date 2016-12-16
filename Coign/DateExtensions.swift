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
    
    fileprivate func formatType(_ form: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US") as Locale!
        dateFormatter.dateFormat = form
        return dateFormatter
    }
    
    var dateFull: Date {
        return Date(timeIntervalSinceReferenceDate: Double(self))
    }
    var toHour: String {
        return formatType("HH:mm").string(from: dateFull as Date)
    }
    
    var toDay: String {
        return formatType("MM/dd/yyyy").string(from: dateFull as Date)
    }
    
    var formatMillisecondsToCoherentTime: String {
        
        let time = (Date.timeIntervalSinceReferenceDate - self)/60

        switch time {
            case 0..<60 :
                return "\(Int(time)) min ago"
            case 60..<120 :
                return "\(Int(time/60)) hour ago"
            case 120..<1440 :
                return "\(Int(time/60)) hours ago"
            case 1440..<2880 :
                return "\(Int(time/60/24)) day ago"
            case 2880..<10080:
                return "\(Int(time/60/24)) days ago"
            case 10080..<20160 :
                return "\(Int(time/60/24/7)) week ago"
            case 20160..<40320 :
                return "\(Int(time/60/24/7)) weeks ago"
            default:
                return self.toDay
        }
    }
}
