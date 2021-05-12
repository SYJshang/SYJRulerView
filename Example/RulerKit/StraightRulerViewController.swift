//
//  StraightRulerViewController.swift
//  RulerKit_Example
//
//  Created by SYJ on 2021/2/5.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RulerKit

class StraightRulerViewController: UIViewController, RulerViewDelegate {
    func rulerSelectValue(value: Double, tag: NSInteger) {
        print("select vale is \(value) is index \(tag)")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.topRuler()
        self.leftRuler()
    }
    
    func topRuler() {
        let numberTopRulerView:RulerView = RulerView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 65))
        numberTopRulerView.backgroundColor = self.HEXCOLOR(c: 0xE4E6EB).withAlphaComponent(0.3)
        numberTopRulerView.tag = 0
        numberTopRulerView.delegate = self
        var config = RulerrConfig()
        //刻度高度
        config.shortScaleLength = 7
        config.longScaleLength = 11
        //刻度宽度
        config.scaleWidth = 2
        //刻度起始位置
        config.shortScaleStart = 7
        config.longScaleStart = 7
        //刻度颜色
        config.scaleColor = HEXCOLOR(c:0xdae0ed)
        //刻度之间的距离
        config.distanceBetweenScale = 4
        //刻度距离数字的距离
        config.distanceFromScaleToNumber = 13
        //指示视图属性设置
        config.pointSize = CGSize(width: 2, height: 20)
        config.pointColor = HEXCOLOR(c:0x20c6ba)
        config.pointStart = 7
        //文字属性
        config.numberFont = UIFont.systemFont(ofSize: 11)
        config.numberColor = HEXCOLOR(c: 0x4A4A4A)
        //数字所在位置方向
        config.numberDirection = .numberBottom
        
        //取值范围
        config.max = 200
        config.min = 0
        //默认值
        config.defaultNumber = 57
        //使用小数类型
        config.isDecimal = true
        //选中
        config.selectionEnable = true
        //使用渐变背景
        config.useGradient = true
        config.infiniteLoop = true
        
        numberTopRulerView.rulerConfig = config
        self.view.addSubview(numberTopRulerView)
    }
    
    func leftRuler() {
        let _numberLeftRulerView:RulerView = RulerView.init(frame: CGRect(x: 20, y: 350, width: 120, height: UIScreen.main.bounds.size.height - 350))
        _numberLeftRulerView.backgroundColor = self.HEXCOLOR(c: 0xE4E6EB).withAlphaComponent(0.3)
        _numberLeftRulerView.tag = 2
        _numberLeftRulerView.delegate = self
        var config = RulerrConfig()
        //刻度高度
        config.shortScaleLength = 12
        config.longScaleLength = 16
        //刻度宽度
        config.scaleWidth = 2
        //刻度起始位置
        config.shortScaleStart = 78
        config.longScaleStart = 74
        //刻度颜色
        config.scaleColor = HEXCOLOR(c: 0xdae0ed)
        //刻度之间的距离
        config.distanceBetweenScale = 4
        //刻度距离数字的距离
        config.distanceFromScaleToNumber = 13
        //指示视图属性设置
        config.pointSize = CGSize(width: 2, height: 20)
        config.pointColor = HEXCOLOR(c:0x20c6ba)
        config.pointStart = 65
        //文字属性
        config.numberFont = UIFont.systemFont(ofSize: 11);
        config.numberColor = HEXCOLOR(c:0x4A4A4A)
        //数字所在位置方向
        config.numberDirection = .numberLeft
        
        //取值范围
        config.max = 100
        config.min = 0
        //默认值
        config.defaultNumber = 25.2
        //使用小数类型
        config.isDecimal = true
        //选中
        config.selectionEnable = true
        //数字顺序相反
        config.reverse = true
        config.infiniteLoop = true
        _numberLeftRulerView.rulerConfig = config
        self.view.addSubview(_numberLeftRulerView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func HEXCOLOR(c: UInt64) -> (UIColor) {
       let redValue = CGFloat((c & 0xFF0000) >> 16)/255.0
       let greenValue = CGFloat((c & 0xFF00) >> 8)/255.0
       let blueValue = CGFloat(c & 0xFF)/255.0
       return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
   }
    
    /** 传入字符串是否是整数数字 */
    static func isInt(str:String?) -> Bool {
        guard let tempStr = str else { return false }
        //string不是浮点型
        if !tempStr.contains(".") {
            let scan = Scanner(string: tempStr)
            var val:Int = 0
            return scan.scanInt(&val) && scan.isAtEnd
        } else {
            //string是浮点型
            let numberArray:Array = tempStr.components(separatedBy: ".")
            if numberArray.count != 2 {
                return false
            } else {
                let behindNumber:String = numberArray[1]
                //如果小数点后的数字等于0，则是整数
                return Int(behindNumber) == 0
            }
            
        }
    }


}
