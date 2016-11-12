//
//  NetworkGraph.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/10/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

@IBDesignable
class NetworkGraph: UIView {

    //MARK: - Properties
    @IBInspectable
    var scale: CGFloat = 0.6 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = CustomColor.darkGreen { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 1 { didSet { setNeedsDisplay() } }
    
    var graphRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    var graphCenter: CGPoint {
        return CGPoint(x:bounds.midX, y: bounds.midY)
    }

    //MARK: Methods

    /* Draw the circle */
    override func draw(_ rect: CGRect) {
        
        let circle = UIBezierPath(
            arcCenter: graphCenter,
            radius: graphRadius,
            startAngle: 0.0,
            endAngle: CGFloat(2*M_PI),
            clockwise: false)
        circle.lineWidth = lineWidth
        color.setFill()
        circle.fill()
    }
 

    
}
