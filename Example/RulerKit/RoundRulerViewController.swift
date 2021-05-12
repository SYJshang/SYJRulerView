//
//  RoundRulerViewController.swift
//  RulerKit_Example
//
//  Created by SYJ on 2021/2/5.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RulerKit


class RoundRulerViewController: UIViewController, RulerValueDelegate {
    
    func rulerValue(_ value: String?) {
        print("current value \(String(describing: value!))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        let rulerRound = RulerRoundView.init(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width))
        rulerRound.backgroundColor = UIColor.white
        rulerRound.delagate = self
        var config = RulerRoundConfig()
        config.startNumber = 0
        config.endNumber = 10
//        config.defaultNumber = 5
        config.isDecimal = true
        rulerRound.config = config
        self.view.addSubview(rulerRound)
        
    }
}
