//
//  StringExtensions.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/18/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation

extension String {
    
    func removeWhitespace() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    

        
    subscript (r: CountableClosedRange<Int>) -> String {
        get {
            let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            return self[startIndex...endIndex]
        }
    }
}
