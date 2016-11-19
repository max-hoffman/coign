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
    
}
