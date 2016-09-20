//
//  ClockView.swift
//  KYClock
//
//  Created by Lawliet on 2016/7/28.
//  Copyright © 2016年 Lawliet. All rights reserved.
//

import UIKit
@IBDesignable
class ClockView: UIView {
    
    var lastFrame:CGRect!
    fileprivate lazy var ticklayer  = CAShapeLayer()
    fileprivate lazy var graduationLayer = CAShapeLayer()
    
    
    fileprivate lazy var secondsLayer : CAShapeLayer={
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.lineWidth = 2
        layer.strokeColor = UIColor.red.cgColor
        layer.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        return layer
    }()
    
    fileprivate lazy var hoursView : HandsView={
        let view = HandsView(frame: self.bounds)
        view.botLength = 25
        view.topLength = 70
        view.handsWidth = 8
        return view
    }()
    
    fileprivate lazy var minutesView:HandsView={
        var view = HandsView(frame: self.bounds)
        view.botLength = 35
        view.topLength = 110
        view.handsWidth = 5
        return view
    }()

    
    fileprivate var deltaAngle = CGFloat()
    fileprivate var startMinutesTransform : CGAffineTransform?


    var oldMinutes : CGFloat?
    var minutesAnimation = CABasicAnimation()
    var hoursAnimation = CABasicAnimation()
    var minutesArc:Double!
    var hoursArc:Double!
    var angle:CGFloat!
    var angleDecide : CGFloat?
    var circleCount:Double = 0
    var canTouch:Bool = true
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setUp()
        
    }
    
    fileprivate func setUp(){
        if let l = lastFrame , l == self.frame{
            return
        }
        
        //------------------------------------------------------Mark:Graduation--------------------------------------------------------
        
        let count = 60
        let path = UIBezierPath()
        let path2 = UIBezierPath()
        
        for tick in 0..<count {
            
            let frame = self.frame
            
            
            if tick % 5 == 0 {
                let x = CGFloat(self.bounds.midX+CGFloat(Double(min(frame.width, frame.height)/3.0-10)*cos(2*M_PI/Double(count)*Double(tick))))
                let y = CGFloat(self.bounds.midY-CGFloat(Double(min(frame.width, frame.height)/3.0-10)*sin(2*M_PI/Double(count)*Double(tick))))
                let len = 40.0
                graduationLayer.lineWidth = 3.0
                graduationLayer.strokeColor = UIColor.black.cgColor
                path2.move(to: CGPoint(x: x, y: y))
                path2.addLine(to: CGPoint(x: x+CGFloat(len*cos(2*M_PI/Double(count)*Double(tick))), y: y-CGFloat(len*sin(2*M_PI/Double(count)*Double(tick)))))
                graduationLayer.path = path2.cgPath
                self.layer.addSublayer(graduationLayer)
                
            } else {
                let x = CGFloat(self.bounds.midX+CGFloat(Double(min(frame.width, frame.height)/3.0)*cos(2*M_PI/Double(count)*Double(tick))))
                let y = CGFloat(self.bounds.midY-CGFloat(Double(min(frame.width, frame.height)/3.0)*sin(2*M_PI/Double(count)*Double(tick))))
                let len = 30.0
                ticklayer.lineWidth = 1.0
                ticklayer.strokeColor = UIColor.black.cgColor
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: x+CGFloat(len*cos(2*M_PI/Double(count)*Double(tick))), y: y-CGFloat(len*sin(2*M_PI/Double(count)*Double(tick)))))
                ticklayer.path = path.cgPath
                self.layer.addSublayer(ticklayer)
            }
            
        }
        
        self.resetHands()
        
        lastFrame = self.frame
        
    }
    
    func resetHands() {
        
        let date = self.getTimeComponent()
        
        print("\(date.hour):\(date.minute):\(date.second)")
        
        let midX = self.bounds.midX
        let midY = self.bounds.midY
        
        let frame = self.frame
        
        let secondsArc = 2*M_PI*(Double(date.second!)/60.0-1/4)
        minutesArc = 2*M_PI*((Double(date.minute!)/60) + (Double(date.second!)/60)/60)
        hoursArc = 2*M_PI*((Double(date.hour!)/12) + (Double(date.minute!)/60)/12)
        
        
        let secondsX = CGFloat(Double(max(frame.height,frame.width)/3.3)*cos(secondsArc))
        let secondsY = CGFloat(Double(max(frame.height,frame.width)/3.3)*sin(secondsArc))
        
//        let minutesY = CGFloat(Double(max(frame.height,frame.width)/4.0))
//        let hoursY = CGFloat(Double(max(frame.height,frame.width)/7.0))
        
        
        //-----------------------------------------------------Mark:hoursHand---------------------------------------------------------
        
        hoursView.transform = CGAffineTransform(rotationAngle: CGFloat(hoursArc))
        self.addSubview(hoursView)
        
        //----------------------------------------------------Mark:minutesHand--------------------------------------------------------
        
        minutesView.transform = CGAffineTransform(rotationAngle: CGFloat(minutesArc))
        self.addSubview(minutesView)
        
        //----------------------------------------------------Mark:secondsHand---------------------------------------------------------
        
        
        let secondsPath = UIBezierPath()
        secondsPath.move(to: CGPoint(x: CGFloat(midX-secondsX/3), y: CGFloat(midY-secondsY/3)))
        secondsPath.addLine(to: CGPoint(x: CGFloat(midX+secondsX), y: CGFloat(midY+secondsY)))
        secondsLayer.path = secondsPath.cgPath
        self.layer.addSublayer(secondsLayer)
        secondsLayer.frame = self.bounds
        
        
        let secondsanimation = CABasicAnimation(keyPath: "transform.rotation.z")
        secondsanimation.duration = 60.0
        secondsanimation.repeatCount = .infinity
        secondsanimation.fromValue = 0.0
        secondsanimation.toValue = 2*M_PI
        secondsLayer.add(secondsanimation, forKey: "secondsRotation")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first{
            let locationPoint = touch.location(in: self)
            let dx = (locationPoint.x) - minutesView.center.x
            let dy = (locationPoint.y) - minutesView.center.y
            deltaAngle = atan2(dx, dy)
            minutesView.transform = CGAffineTransform(rotationAngle: -deltaAngle+CGFloat(M_PI))
            startMinutesTransform = minutesView.transform
        }

    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let movePoint = touches.first!.location(in: self)
        let dx = (movePoint.x) - minutesView.center.x
        let dy = (movePoint.y) - minutesView.center.y
        
        let previousLocation = touches.first!.previousLocation(in: self)
        let preDx = (previousLocation.x) - minutesView.center.x
        let preDy = (previousLocation.y) - minutesView.center.y
        
        let ang = atan2(dx, dy)
        let angleDifference = deltaAngle - ang

        let angle = atan2(minutesView.transform.b, minutesView.transform.a)
        
        minutesView.transform = startMinutesTransform!.rotated(by: angleDifference)
        
        
        if (dy>0 && preDx*dx<=0 && dx-preDx<0 && preDx != 0 && preDy>0){
            circleCount += 1
        } else if (dy>0 && preDx*dx<=0 && preDx-dx<0 && preDx != 0 && preDy>0){
            circleCount -= 1
        }
        
        angleDecide = (angleDecide == nil) ? angle : angleDecide
        
        let angleCorrection = (angle-CGFloat(minutesArc))/12
        
        let circleAngle = CGFloat(circleCount*2*M_PI/12)+CGFloat(hoursArc)+CGFloat(angleCorrection)
        
        hoursView.transform = CGAffineTransform(rotationAngle: circleAngle)
        
    }
    
    
    func getTimeComponent() -> DateComponents{
        let calendar = Calendar.current
        let currentDate = Date()
        let dateComponents = (calendar as NSCalendar).components([.hour,.minute,.second], from: currentDate)
        return dateComponents
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if (canTouch == true) {
            return self
        }
        return nil
    }
}
    
    

