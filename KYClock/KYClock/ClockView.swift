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
    private lazy var ticklayer  = CAShapeLayer()
    private lazy var graduationLayer = CAShapeLayer()
    
    
    private lazy var minutesLayer : CAShapeLayer={
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.lineWidth = 5
        layer.strokeColor = UIColor.blackColor().CGColor
        layer.anchorPoint = CGPointMake(0.5,0.5)
        return layer
    }()
    
    private lazy var secondsLayer : CAShapeLayer={
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.lineWidth = 2
        layer.strokeColor = UIColor.redColor().CGColor
        layer.anchorPoint = CGPointMake(0.5,0.5)
        return layer
    }()
    
    private lazy var hoursLayer : CAShapeLayer={
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.lineWidth = 8
        layer.strokeColor = UIColor.blackColor().CGColor
        layer.anchorPoint = CGPointMake(0.5,0.5)
        return layer
    }()
    
    
    private var deltaAngle = CGFloat()
    private var startMinutesTransform : CATransform3D?
    var oldMinutes : CGFloat?
    var minutesAnimation = CABasicAnimation()
    var hoursAnimation = CABasicAnimation()
    var minutesArc:Double = 0.0
    var hoursArc:Double = 0.0
    var angle:CGFloat = 0.0
    var angleDecide : CGFloat?
    var circleCount:Double = 0
    var canTouch:Bool = true
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setUp()
        
    }
    
    private func setUp(){
        if let l = lastFrame where l == self.frame{
            return
        }
        
        //------------------------------------------------------Mark:Graduation--------------------------------------------------------
        
        let count = 60
        let path = UIBezierPath()
        let path2 = UIBezierPath()
        
        for tick in 0..<count {
            
            let frame = self.frame
            
            
            if tick % 5 == 0 {
                let x = CGFloat(CGRectGetMidX(self.bounds)+CGFloat(Double(min(frame.width, frame.height)/3.0-10)*cos(2*M_PI/Double(count)*Double(tick))))
                let y = CGFloat(CGRectGetMidY(self.bounds)-CGFloat(Double(min(frame.width, frame.height)/3.0-10)*sin(2*M_PI/Double(count)*Double(tick))))
                let len = 40.0
                graduationLayer.lineWidth = 3.0
                graduationLayer.strokeColor = UIColor.blackColor().CGColor
                path2.moveToPoint(CGPointMake(x, y))
                path2.addLineToPoint(CGPointMake(x+CGFloat(len*cos(2*M_PI/Double(count)*Double(tick))), y-CGFloat(len*sin(2*M_PI/Double(count)*Double(tick)))))
                graduationLayer.path = path2.CGPath
                self.layer.addSublayer(graduationLayer)
                
            } else {
                let x = CGFloat(CGRectGetMidX(self.bounds)+CGFloat(Double(min(frame.width, frame.height)/3.0)*cos(2*M_PI/Double(count)*Double(tick))))
                let y = CGFloat(CGRectGetMidY(self.bounds)-CGFloat(Double(min(frame.width, frame.height)/3.0)*sin(2*M_PI/Double(count)*Double(tick))))
                let len = 30.0
                ticklayer.lineWidth = 1.0
                ticklayer.strokeColor = UIColor.blackColor().CGColor
                path.moveToPoint(CGPointMake(x, y))
                path.addLineToPoint(CGPointMake(x+CGFloat(len*cos(2*M_PI/Double(count)*Double(tick))), y-CGFloat(len*sin(2*M_PI/Double(count)*Double(tick)))))
                ticklayer.path = path.CGPath
                self.layer.addSublayer(ticklayer)
            }
            
        }
        
        self.resetHands()
        
        lastFrame = self.frame
        
    }
    
    func resetHands() {
        
        let date = self.getTimeComponent()
        
        print("\(date.hour):\(date.minute):\(date.second)")
        
        let midX = CGRectGetMidX(self.bounds)
        let midY = CGRectGetMidY(self.bounds)
        
        let frame = self.frame
        
        let secondsArc = 2*M_PI*(Double(date.second)/60.0-1/4)
        minutesArc = 2*M_PI*((Double(date.minute)/60) + (Double(date.second)/60)/60)
        hoursArc = 2*M_PI*((Double(date.hour)/12) + (Double(date.minute)/60)/12)
        
        
        let secondsX = CGFloat(Double(max(frame.height,frame.width)/3.3)*cos(secondsArc))
        let secondsY = CGFloat(Double(max(frame.height,frame.width)/3.3)*sin(secondsArc))
        
        let minutesY = CGFloat(Double(max(frame.height,frame.width)/4.0))
        let hoursY = CGFloat(Double(max(frame.height,frame.width)/7.0))
        
        
        
        //-----------------------------------------------------Mark:hoursHand---------------------------------------------------------
        
        
        let hoursPath = UIBezierPath()
        hoursPath.moveToPoint(CGPointMake(CGFloat(midX), CGFloat(midY-hoursY)))
        hoursPath.addLineToPoint(CGPointMake(CGFloat(midX), CGFloat(midY+hoursY/3)))
        hoursLayer.path = hoursPath.CGPath
        hoursLayer.transform = CATransform3DMakeRotation(CGFloat(hoursArc), 0.0, 0.0, 1.0)
        self.layer.addSublayer(hoursLayer)
        self.hoursHandAnimation()
        
        
        //----------------------------------------------------Mark:minutesHand--------------------------------------------------------
        
        
        let minutesPath = UIBezierPath()
        minutesPath.moveToPoint(CGPointMake(CGFloat(midX), CGFloat(midY-minutesY)))
        minutesPath.addLineToPoint(CGPointMake(CGFloat(midX), CGFloat(midY+minutesY/3)))
        minutesLayer.path = minutesPath.CGPath
        minutesLayer.transform = CATransform3DMakeRotation(CGFloat(minutesArc), 0.0, 0.0, 1.0)
        self.layer.addSublayer(minutesLayer)
        self.minutesHandAnimation()
        
        
        //---------------------------------------------------Mark:secondsHand---------------------------------------------------------
        
        
        let secondsPath = UIBezierPath()
        secondsPath.moveToPoint(CGPointMake(CGFloat(midX-secondsX/3), CGFloat(midY-secondsY/3)))
        secondsPath.addLineToPoint(CGPointMake(CGFloat(midX+secondsX), CGFloat(midY+secondsY)))
        secondsLayer.path = secondsPath.CGPath
        self.layer.addSublayer(secondsLayer)
        secondsLayer.frame = self.bounds
        
        
        let secondsanimation = CABasicAnimation(keyPath: "transform.rotation.z")
        secondsanimation.duration = 60.0
        secondsanimation.repeatCount = .infinity
        secondsanimation.fromValue = 0.0
        secondsanimation.toValue = 2*M_PI
        secondsLayer.addAnimation(secondsanimation, forKey: "secondsRotation")
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let locationPoint = (touches as NSSet).anyObject()?.locationInView(self)
        let dx = (locationPoint?.x)! - minutesLayer.position.x
        let dy = (locationPoint?.y)! - minutesLayer.position.y
        deltaAngle = atan2(dx, dy)
        minutesLayer.transform = CATransform3DMakeRotation(-deltaAngle+CGFloat(M_PI), 0.0, 0.0, 1.0)
        startMinutesTransform = minutesLayer.transform
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        
        
        let movePoint = (touches as NSSet).anyObject()?.locationInView(self)
        let dx = (movePoint?.x)! - minutesLayer.position.x
        let dy = (movePoint?.y)! - minutesLayer.position.y
        
        let previousLocation = (touches as NSSet).anyObject()?.previousLocationInView(self)
        let preDx = (previousLocation?.x)! - minutesLayer.position.x
        let preDy = (previousLocation?.y)! - minutesLayer.position.y
        
        let ang = atan2(dx, dy)
        let angleDifference = deltaAngle - ang
        var angleCorrection :CGFloat!
        let angle = atan2(minutesLayer.transform.m12, minutesLayer.transform.m11)
        
        
        minutesLayer.transform = CATransform3DRotate(startMinutesTransform!, angleDifference, 0.0, 0.0, 1.0)
        
        
        
        if (dy>0 && preDx*dx<=0 && dx-preDx<0 && preDx != 0 && preDy>0){
            circleCount += 1
        } else if (dy>0 && preDx*dx<=0 && preDx-dx<0 && preDx != 0 && preDy>0){
            circleCount -= 1
        }
        
        if angleDecide == nil {
            angleDecide = angle
        }
        
        
        if angleDecide>0 {
            angleCorrection = (angle-CGFloat(minutesArc))/12
        } else if angleDecide<0{
            angleCorrection = (angle+(CGFloat(2*M_PI))-CGFloat(minutesArc))/12
        }
        
        let circleAngle = angleCorrection + CGFloat(hoursArc) + CGFloat(circleCount*2*M_PI/12)
        hoursLayer.transform = CATransform3DMakeRotation(circleAngle, 0.0, 0.0, 1.0)
        
        
        minutesLayer.removeAnimationForKey("minutesRotation")
        hoursLayer.removeAnimationForKey("hoursRotation")
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("end")
        
        self.minutesHandAnimation()
        self.hoursHandAnimation()
    }
    
    
    private func minutesHandAnimation() {
        
        minutesAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        minutesAnimation.duration = 3600.0
        minutesAnimation.repeatCount = .infinity
        minutesAnimation.byValue = 2*M_PI
        minutesLayer.addAnimation(minutesAnimation, forKey: "minutesRotation")
        
    }
    
    private func hoursHandAnimation() {
        
        hoursAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        hoursAnimation.duration = 43200.0
        hoursAnimation.repeatCount = .infinity
        hoursAnimation.byValue = 2*M_PI
        hoursLayer.addAnimation(hoursAnimation, forKey: "hoursRotation")
        
        
    }
    
    func getTimeComponent() -> NSDateComponents{
        let calendar = NSCalendar.currentCalendar()
        let currentDate = NSDate()
        let dateComponents = calendar.components([.Hour,.Minute,.Second], fromDate: currentDate)
        return dateComponents
    }
    
    
    
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if (canTouch == true) {
            return self
        }
        return nil
    }
    
    
}
