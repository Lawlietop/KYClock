//
//  HandsView.swift
//  KYClock
//
//  Created by cuber7788 on 2016/9/13.
//  Copyright © 2016年 Lawliet. All rights reserved.
//

import UIKit

class HandsView: UIView {

    var topLength : CGFloat!
    var botLength : CGFloat!
    var handsWidth : CGFloat!
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
       super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let center = self.center
        let top = CGPoint(x: center.x, y: center.y-self.topLength)
        let bot = CGPoint(x: center.x, y: center.y+self.botLength)

        let path  = UIBezierPath()
        path.move(to: top)
        path.addLine(to: bot)
        path.lineWidth = handsWidth
        path.stroke()
    }
    
    
}
