//
//  RulerMachineView.swift
//  RulerKit
//
//  Created by SYJ on 2021/2/5.
//

import UIKit

public struct RulerRoundConfig {
    /// 内圈颜色
    public var firstLineColor: UIColor = UIColor.green
    /// 中圈颜色
    public var secondLineColor: UIColor = UIColor.blue
    /// 外圈颜色
    public var thirdLineColor: UIColor = UIColor.green
    /// 字体大小
    public var fontSize: CGFloat = 12.0
    /// 开始数字
    public var startNumber = 0
    /// 结束数字
    public var endNumber = 100
    /// 字体颜色
    public var fontColor: UIColor = UIColor.black
    /// 短线长度
    public var shortLine: CGFloat = 5.0
    /// 中线长度
    public var middleLine: CGFloat = 10.0
    /// 长线长度
    public var longLine: CGFloat = 15.0
    /// 默认值
    public var defaultNumber = 0
    /// 短刻度颜色
    public var shortScaleColor: UIColor = UIColor.lightGray
    /// 中刻度线颜色
    public var middleScaleColor: UIColor = UIColor.lightGray
    /// 长刻度颜色
    public var longScaleColor: UIColor = UIColor.gray
    /// 中圈距离外圈的距离
    public var distanceOuter: CGFloat = 20.0
    /// 内圈距离外圈的距离
    public var distanceInner: CGFloat = 60.0
    /// 外圈宽度
    public var outerLineWidth: CGFloat = 2.0
    /// 中圈宽度
    public var middleLineWidth: CGFloat = 10.0
    /// 内圈宽度
    public var innerLineWidth: CGFloat = 2.0
    /// 是否支持小数
    public var isDecimal = false
    /// 箭头颜色
    public var arrowColor:UIColor = UIColor.black

    
    public init () {
        
    }
}

class RulerMachineView: UIImageView {

    var config:RulerRoundConfig = RulerRoundConfig()
    /** 半径长度 */
    var radiu:CGFloat = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.radiu = frame.size.width / 2.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.drawFirstArc()
        self.drawSecondArc()
        self.drawThirdArc()
        self.drawOutsideArc()
    }
    
    ///内圈线
    func drawFirstArc() {
        let startAngel:CGFloat = 0.0
        let endAngel:CGFloat = CGFloat(2 * Double.pi)
        let tickPath = UIBezierPath.init(arcCenter: self.center, radius: self.radiu - self.config.distanceInner, startAngle: startAngel, endAngle: endAngel, clockwise: true)
        let perLayer:CAShapeLayer = CAShapeLayer()
        perLayer.strokeColor = self.config.firstLineColor.cgColor
        perLayer.lineWidth = self.config.innerLineWidth
        perLayer.fillColor = UIColor.clear.cgColor
        perLayer.path = tickPath.cgPath
        self.layer.addSublayer(perLayer)
    }
    
    ///中圈线
    func drawSecondArc() {
        let startAngel:CGFloat = 0.0
        let endAngel:CGFloat = CGFloat(2 * Double.pi)
        let tickPath = UIBezierPath.init(arcCenter: self.center, radius: self.radiu - self.config.distanceOuter, startAngle: startAngel, endAngle: endAngel, clockwise: true)
        let perLayer:CAShapeLayer = CAShapeLayer()
        perLayer.strokeColor = self.config.secondLineColor.cgColor
        perLayer.lineWidth = self.config.middleLineWidth
        perLayer.fillColor = UIColor.clear.cgColor
        perLayer.path = tickPath.cgPath
        self.layer.addSublayer(perLayer)
    }
    
    ///外圈线
    func drawThirdArc() {
        let startAngel:CGFloat = 0.0
        let endAngel:CGFloat = CGFloat(2 * Double.pi)
        let tickPath = UIBezierPath.init(arcCenter: self.center, radius: self.radiu - 1, startAngle: startAngel, endAngle: endAngel, clockwise: true)
        let perLayer:CAShapeLayer = CAShapeLayer()
        perLayer.strokeColor = self.config.thirdLineColor.cgColor
        perLayer.lineWidth = self.config.outerLineWidth
        perLayer.fillColor = UIColor.clear.cgColor
        perLayer.path = tickPath.cgPath
        self.layer.addSublayer(perLayer)
    }
    
    ///刻度线
    func drawOutsideArc() {
        let sAngel:CGFloat = CGFloat(Double.pi / 2 * 3)
        let eAngel:CGFloat = CGFloat(-(Double.pi / 2))
        if self.config.isDecimal == true {
            self.config.startNumber = self.config.startNumber * 10
            self.config.endNumber = self.config.endNumber * 10
            self.config.defaultNumber = self.config.defaultNumber * 10
        }
        let perAngle:CGFloat = (sAngel - eAngel) / CGFloat((self.config.endNumber - self.config.startNumber))
        //我们需要计算出每段弧线的起始角度和结束角度
        //这里我们从- M_PI 开始，我们需要理解与明白的是我们画的弧线与内侧弧线是同一个圆心
        for i in 0 ..< (self.config.endNumber - self.config.startNumber) {
            let startAngel:CGFloat = (sAngel + perAngle * CGFloat(i))
            let endAngel:CGFloat =  startAngel + perAngle / 8
            let tickPath = UIBezierPath.init(arcCenter: self.center, radius: self.radiu - self.config.distanceOuter - self.config.middleLineWidth - self.config.outerLineWidth, startAngle: startAngel, endAngle: endAngel, clockwise: true)
            let perLayer:CAShapeLayer = CAShapeLayer()
            if (i % 10 == 0) {
                perLayer.lineWidth = self.config.longLine
                perLayer.strokeColor = self.config.longScaleColor.cgColor
                var value:CGFloat = 0
                if (self.config.defaultNumber == 0) {
                    value = CGFloat(i + self.config.startNumber)
                } else {
                    if ((i + self.config.defaultNumber) < self.config.endNumber) {
                        value = CGFloat(i + self.config.defaultNumber)
                    } else {
                        value = CGFloat(self.config.defaultNumber - ((self.config.endNumber - self.config.startNumber) - i))
                    }
                }
                self.drawOutsideScaleWithAngel(textAngel: endAngel, index: value)
            } else if (i % 5 == 0) {
                perLayer.lineWidth = self.config.middleLine
                perLayer.strokeColor = self.config.middleScaleColor.cgColor
            } else {
                perLayer.lineWidth = self.config.shortLine
                perLayer.strokeColor = self.config.shortScaleColor.cgColor
            }
            perLayer.path = tickPath.cgPath
            self.layer.addSublayer(perLayer)
        }
    }
    
    func drawOutsideScaleWithAngel(textAngel:CGFloat, index:CGFloat) {
        let point = self.calculateTextPositonWithArcCenter(center: self.center, angle: -textAngel)
        var tickText = ""
        if (self.config.isDecimal) {
            tickText = String(format: "%.1f", index / 10)
        } else {
            tickText = String(format: "%d", Int(index))
        }
        //默认label的大小30 * 14
        let text = UILabel.init(frame: CGRect(x: point.x - 15, y: point.y - 8, width: 30, height: 14))
        text.text = tickText
        text.font = UIFont.systemFont(ofSize: self.config.fontSize)
        text.textColor = self.config.fontColor
        text.textAlignment = .center
        text.transform = CGAffineTransform(rotationAngle: (CGFloat(Double.pi / 2) + textAngel))
        text.sizeToFit()
        self.addSubview(text)
    }
    
    func calculateTextPositonWithArcCenter(center:CGPoint, angle:CGFloat) -> CGPoint {
        let x:CGFloat = CGFloat((self.radiu - self.config.distanceOuter - self.config.middleLineWidth - self.config.outerLineWidth - self.config.longLine) * CGFloat(cosf(Float(angle))))
        let y:CGFloat = CGFloat((self.radiu - self.config.distanceOuter - self.config.middleLineWidth - self.config.outerLineWidth - self.config.longLine) * CGFloat(sinf(Float(angle))))
        return CGPoint(x: center.x + x, y: center.y - y)
    }

}

