//
//  RulerRoundView.swift
//  RulerKit
//
//  Created by SYJ on 2021/2/5.
//

import UIKit

public protocol RulerValueDelegate: NSObjectProtocol {
    func rulerValue(_ value: String?)
}

public class RulerRoundView: UIView {

    public var config = RulerRoundConfig()
    public var delagate:RulerValueDelegate?
    
    private let pboneRound:Double = 6.2831855 //一圈的弧度 = 360度
    
    private var rrPanel:RulerRoundRotatePanel?
    private var rulerView:RulerMachineView?
    private var changedRadian:Double = 0.0
    private var bgView:UIView?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.rrPanel = RulerRoundRotatePanel.init(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.rrPanel?.centerPoint = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.rrPanel?.addTarget(self, action: #selector(colorPanelRotated), for: .valueChanged)
        self.addSubview(self.rrPanel!)
        
        self.rulerView = RulerMachineView.init(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.rrPanel?.addSubview(self.rulerView!)
        
        self.bgView = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height / 2, width: self.frame.size.width, height: self.frame.size.height / 2))
        self.addSubview(self.bgView!)

    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView?.backgroundColor = self.backgroundColor
        self.rulerView?.config = self.config
        self.drawArrowArc()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func colorPanelRotated() {
        self.changedRadian += Double(self.rrPanel!.changedRadian)
        if (self.changedRadian > pboneRound) {
            self.changedRadian -=  pboneRound
        } else if (self.changedRadian < -pboneRound) {
            self.changedRadian += pboneRound
        }
        
        var value:CGFloat = 0
        if self.config.defaultNumber == 0 {
            value = (CGFloat((self.config.startNumber - self.config.endNumber)) / CGFloat((2 * Double.pi)) * CGFloat((self.changedRadian)))
            if (self.config.isDecimal == true) {
                value = CGFloat(roundf(Float(value * 10)))
                if (value < 0) {
                    value = CGFloat(self.config.endNumber * 10) + value
                } else {
                    value = CGFloat(self.config.startNumber) + value
                }
                value = value / 10
            } else {
                if (value < 0) {
                    value = CGFloat(self.config.endNumber) + value
                } else {
                    value = CGFloat(self.config.startNumber) + value
                }
            }
        } else {
            value = (CGFloat((self.config.startNumber - self.config.endNumber)) / CGFloat((2 * Double.pi)) * CGFloat((self.changedRadian))) + CGFloat(self.config.defaultNumber)
            if (self.config.isDecimal == true) {
                value = CGFloat(roundf(Float(value * 10)))
                if (value < 0) {
                    value = CGFloat(self.config.endNumber * 10) + value
                } else {
                    value = CGFloat(self.config.startNumber) + value
                }
                value = value / 10
            } else {
                if (value > CGFloat(self.config.endNumber)) {
                    value = value - CGFloat(self.config.endNumber + self.config.startNumber)
                }else if (value < CGFloat(self.config.startNumber)) {
                    value = CGFloat(self.config.endNumber) - (CGFloat(self.config.startNumber) - value)
                }
            }

        }
        if self.config.isDecimal {
            let numberValue = NSDecimalNumber.init(value: Double(value))
            let roundingBehavior = NSDecimalNumberHandler.init(roundingMode: .plain, scale: 1, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
            self.delagate?.rulerValue(String(format: "%@", numberValue.rounding(accordingToBehavior: roundingBehavior)))
        } else {
            let numberValue = NSDecimalNumber.init(value: Int(roundf(Float(value))))
            let roundingBehavior = NSDecimalNumberHandler.init(roundingMode: .plain, scale: 1, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
            self.delagate?.rulerValue(String(format: "%@", numberValue.rounding(accordingToBehavior: roundingBehavior)))
        }
    }
    
    func drawArrowArc() {
        let arrow = UIBezierPath()
        arrow.addArrow(start: CGPoint(x: center.x - 1, y: self.config.distanceInner + 60), end: CGPoint(x: center.x - 1, y: self.config.distanceInner + 20), pointerLineLength: 20, arrowAngle: CGFloat(Double.pi / 4))
        let arrowLayer = CAShapeLayer()
        arrowLayer.strokeColor = self.config.arrowColor.cgColor
        arrowLayer.lineWidth = 2
        arrowLayer.path = arrow.cgPath
        arrowLayer.fillColor = UIColor.clear.cgColor
        arrowLayer.lineJoin = kCALineJoinRound
        arrowLayer.lineCap = kCALineCapRound
        self.layer.addSublayer(arrowLayer)
    }
}

extension UIBezierPath {
    func addArrow(start: CGPoint, end: CGPoint, pointerLineLength: CGFloat, arrowAngle: CGFloat) {
        self.move(to: start)
        self.addLine(to: end)

        let startEndAngle = atan((end.y - start.y) / (end.x - start.x)) + ((end.x - start.x) < 0 ? CGFloat(Double.pi) : 0)
        let arrowLine1 = CGPoint(x: end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle + arrowAngle), y: end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle + arrowAngle))
        let arrowLine2 = CGPoint(x: end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle - arrowAngle), y: end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle - arrowAngle))

        self.addLine(to: arrowLine1)
        self.move(to: end)
        self.addLine(to: arrowLine2)
    }
}
