//
//  Constants.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/8/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

enum CustomColor {
//    static let darkGreen = UIColor(red: 0, green: 0.5569, blue: 0.0824, alpha: 1.0)
    static let darkGreen = UIColor(netHex:0x005000)
}


struct Charities {
    static let list = ["dafault charity:", "American Red Cross", "Feeding America", "Smithsonian Institution", "City of Hope", "Dana-Farber Cancer Institute", "World Vision", "St. Jude Children's Research Hospital", "Food For The Poor", "American Cancer Society", "The Nature Conservancy"]
}

enum Storyboard: String {
    case Login = "Login"
    case MainMenu = "MainMenu"
    case MainApp = "MainApp"
    case Settings = "Settings"
    case AboutUs = "AboutUs"
}

enum ViewController: String {
    case Settings = "Settings"
    case FAQ = "FAQ"
}

