//
//  ContentViewInTourist.swift
//  Project
//
//  Created by apple on 4/28/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class ContentViewInTourist: UIView {

  var line =  UIBezierPath()

    func drawLine() {
        line.move(to: CGPoint(x: 40, y: 400))
        line.addLine(to: CGPoint(x: (bounds.width) - 40, y: 400))
        UIColor.black.setStroke()
        line.lineWidth = 0.1
        line.stroke()

    }
    
    func drawSecondLine() {
        line.move(to: CGPoint(x: 40, y: 565))
        line.addLine(to: CGPoint(x: (bounds.width) - 40, y: 565))
        UIColor.black.setStroke()
        line.lineWidth = 0.2
        line.stroke()

    }

    override func draw(_ rect: CGRect) {
        drawLine()
        drawSecondLine()
    }


}
