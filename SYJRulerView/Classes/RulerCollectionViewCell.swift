//
//  RulerCollectionViewCell.swift
//  RulerKit
//
//  Created by SYJ on 2020/12/30.
//

import UIKit

let SCREEN_WIDTH_RULER:CGFloat = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT_RULER:CGFloat = UIScreen.main.bounds.size.height

class RulerCollectionViewCell: UICollectionViewCell {
    
    public var rulerConfig:RulerrConfig?
    public var index:NSInteger = 0
    
    lazy var ruleImageView: UIImageView = {
        let ruleImageView = UIImageView()
        return ruleImageView
    }()
    
    lazy var textLayer: CATextLayer = {
        let textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = "center"
        return textLayer
    }()
    
    lazy var selectTextLayer: CATextLayer = {
        let textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.contentView.backgroundColor = UIColor.gray
        self.contentView.addSubview(self.ruleImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (self.index % 10) == 0 {

            var text = ""
            if ((self.rulerConfig?.isDecimal) != nil) {
                var showIndex = self.index / 10 + self.rulerConfig!.min
                if self.rulerConfig!.reverse {
                    showIndex = self.rulerConfig!.max - showIndex + self.rulerConfig!.min
                    text = String(showIndex)
                } else {
                    text = String(self.index / 10 + self.rulerConfig!.min)
                }
            } else {
                let showIndex = self.index / 10 + self.rulerConfig!.min
                if self.rulerConfig!.reverse {
                    text = String((self.rulerConfig!.max - showIndex + self.rulerConfig!.min))
                } else {
                    text = String(showIndex)
                }
            }

            //?????? (??????????????????????????????????????????)
            let tempStr = self.maxString()
            let size:CGSize = (tempStr.boundingRect(with: CGSize(width: SCREEN_WIDTH_RULER, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.rulerConfig!.numberFont], context: nil)).size
            if (self.rulerConfig!.numberDirection == RulerNumberDirection.numberTop) || (self.rulerConfig!.numberDirection == RulerNumberDirection.numberBottom) {
                //????????????
                var startY:CGFloat = 0
                if (self.rulerConfig!.numberDirection == RulerNumberDirection.numberTop) {
                    //????????????????????????????????????
                    startY = self.rulerConfig!.shortScaleStart - self.rulerConfig!.distanceFromScaleToNumber - size.height
                } else if (self.rulerConfig!.numberDirection == RulerNumberDirection.numberBottom) {
                    //????????????????????????????????????
                    startY = self.rulerConfig!.shortScaleStart + self.rulerConfig!.shortScaleLength + self.rulerConfig!.distanceFromScaleToNumber
                }
                self.textLayer.frame = CGRect(x: ((self.contentView.frame).width - size.width) / 2.0, y: startY, width: size.width, height: size.height)
            } else {
                //????????????
                var startX:CGFloat = 0
                if (self.rulerConfig!.numberDirection == .numberLeft) {
                    //????????????????????????????????????
                    startX = self.rulerConfig!.shortScaleStart - self.rulerConfig!.distanceFromScaleToNumber - size.width
                } else if (self.rulerConfig!.numberDirection == .numberRight){
                    //????????????????????????????????????
                    startX = self.rulerConfig!.shortScaleStart + self.rulerConfig!.shortScaleLength + self.rulerConfig!.distanceFromScaleToNumber
                }
                self.textLayer.frame = CGRect(x: startX, y: ((self.contentView.frame).height - size.height)/2.0, width: size.width, height: size.height)
            }
            self.textLayer.string = NSAttributedString.init(string: text, attributes: [NSAttributedString.Key.font : self.rulerConfig!.numberFont,
                                                                                 NSAttributedString.Key.foregroundColor : self.rulerConfig!.numberColor])
            self.textLayer.actions = ["contents":NSNull()]
            if (self.textLayer.superlayer == nil) {
                self.contentView.layer.addSublayer(self.textLayer)
            }
        } else {
            self.textLayer.string = nil
        }
        self.selectTextLayer.string = nil
        self.selectTextLayer.removeFromSuperlayer()
        //?????????
        let length:CGFloat = ((self.index % 5 == 0) ? self.rulerConfig!.longScaleLength : self.rulerConfig!.shortScaleLength)
        let start:CGFloat = ((self.index % 5 == 0) ? self.rulerConfig!.longScaleStart : self.rulerConfig!.shortScaleStart)
        let kHorizontalCell = (self.rulerConfig!.numberDirection == .numberTop) || (self.rulerConfig!.numberDirection == .numberBottom)
        self.ruleImageView.frame = kHorizontalCell ? CGRect(x: 0, y: start, width: self.rulerConfig!.scaleWidth, height: length) : CGRect(x: start, y: 0, width: length, height: self.rulerConfig!.scaleWidth)
        self.ruleImageView.layer.cornerRadius = self.rulerConfig!.scaleWidth / 2.0
        self.ruleImageView.backgroundColor = self.rulerConfig!.scaleColor

    }
    
    /// ????????????????????????????????????????????????
    /// - Returns: ????????????????????????
    func maxString() -> String {
        var num:NSInteger = self.rulerConfig!.max
        var maxNumberString:String = ""
        while num > 0 {
            maxNumberString.append("9")
            num = num / 10
        }
       return maxNumberString
    }
    
    /// ?????????????????????
    /// - Parameters:
    ///   - price: ?????????????????????
    ///   - afterPoint: ????????????????????????
    /// - Returns: ??????
    func notRounding(price:Float, afterPoint:Int) -> String {
        let roundingBehavior:NSDecimalNumberHandler = NSDecimalNumberHandler.init(roundingMode: .plain, scale: Int16(afterPoint), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let ouncesDecimal:NSDecimalNumber
        let roundedOunces:NSDecimalNumber
        ouncesDecimal = NSDecimalNumber.init(value: price)
        roundedOunces = ouncesDecimal.rounding(accordingToBehavior: roundingBehavior)
        return NSString(format: "%@", roundedOunces) as String
    }
    
}

extension RulerCollectionViewCell {
    
    /// ????????????cell
    public func makeCellSelect() {
        self.selectTextLayer.contents = nil
        var text:String = ""
        if self.rulerConfig!.isDecimal {
            var showIndex:Double = Double(Double(self.index) / Double(10.0) + Double(self.rulerConfig!.min))
            if self.rulerConfig!.reverse {
                showIndex = Double(Double(self.rulerConfig!.max) - Double(showIndex) + Double(self.rulerConfig!.min))
                text = self.notRounding(price: Float(showIndex), afterPoint: 1)
            } else {
                text = self.notRounding(price: Float(self.index) / 10.0 + Float(self.rulerConfig!.min), afterPoint: 1)
            }
        }else {
            let showIndex:NSInteger =  self.index + self.rulerConfig!.min
            if self.rulerConfig!.reverse {
                text = String((self.rulerConfig!.max - showIndex + self.rulerConfig!.min))
            } else {
                text = String(showIndex)
            }
        }
        let size:CGSize = (text.boundingRect(with: CGSize(width: SCREEN_WIDTH_RULER, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], attributes: [NSAttributedString.Key.font: UIFont.init(name: "PingFangSC-Semibold", size: 18)!], context: nil)).size
        if (self.rulerConfig!.numberDirection == RulerNumberDirection.numberTop) || (self.rulerConfig!.numberDirection == RulerNumberDirection.numberBottom) {
            //????????????
            var startY:CGFloat = 0
            if (self.rulerConfig!.numberDirection == RulerNumberDirection.numberTop) {
                //????????????????????????????????????
                startY = self.rulerConfig!.shortScaleStart - self.rulerConfig!.distanceFromScaleToNumber - size.height - 12
            } else if (self.rulerConfig!.numberDirection == RulerNumberDirection.numberBottom) {
                //????????????????????????????????????
                startY = self.rulerConfig!.shortScaleStart + self.rulerConfig!.shortScaleLength + self.rulerConfig!.distanceFromScaleToNumber + 12
            }
            self.selectTextLayer.frame = CGRect(x: ((self.contentView.frame).width - size.width) / 2.0, y: startY, width: size.width, height: size.height)

        } else {
            //????????????
            var startX:CGFloat = 0
            if (self.rulerConfig!.numberDirection == .numberLeft) {
                //????????????????????????????????????
                startX = self.rulerConfig!.shortScaleStart - self.rulerConfig!.distanceFromScaleToNumber - size.width - 12
            } else if (self.rulerConfig!.numberDirection == .numberRight){
                //????????????????????????????????????
                startX = self.rulerConfig!.shortScaleStart + self.rulerConfig!.shortScaleLength + self.rulerConfig!.distanceFromScaleToNumber + 12
            }
            self.selectTextLayer.frame = CGRect(x: startX, y: ((self.contentView.frame).height - size.height)/2.0, width: size.width, height: size.height)
        }
        self.selectTextLayer.string = NSAttributedString.init(string: text, attributes: [NSAttributedString.Key.font : UIFont.init(name: "PingFangSC-Semibold", size: 18) as Any,NSAttributedString.Key.foregroundColor : HEXCOLOR(c: 0x20C6BA)])
        self.selectTextLayer.actions = ["contents": NSNull()];
        self.contentView.layer.addSublayer(self.selectTextLayer)
        self.textLayer.string = nil
    }
    
    /// ????????????cell?????????
    public func makeCellHiddenText() {
        self.textLayer.string = nil
    }
    
}
