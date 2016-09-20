//
//  ViewController.swift
//  KYClock
//
//  Created by Lawliet on 2016/7/28.
//  Copyright © 2016年 Lawliet. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var clockView: ClockView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    
    @IBAction func switchBtnAction(_ sender: AnyObject) {
        if switchBtn.isOn {
            clockView.canTouch = true
        }else{
            clockView.canTouch = false
        }
    }
    @IBAction func resetClock(_ sender: AnyObject) {
        clockView.resetHands()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

