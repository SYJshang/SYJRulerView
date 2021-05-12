//
//  RulerRoundRotatePanel.swift
//  RulerKit
//
//  Created by SYJ on 2021/2/5.
//

import UIKit

class RulerRoundRotatePanel: UIControl {

    /** 中心点的坐标值 */
    var centerPoint:CGPoint?
    /** 滑动改变值 */
    var changedRadian:CGFloat = 0
    
    //跟踪触摸事件
    //只不过UIControl的是针对单点触摸，而UIResponse可能是多点触摸。另外，返回值也是大同小异。由于UIControl本身是视图，所以它实际上也继承了UIResponse的这四个方法。如果测试一下，我们会发现在针对控件的触摸事件发生时，这两组方法都会被调用，而且互不干涉。
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)
        let previousRadian = self.radianToCenterPoint(centerPoint: self.centerPoint ?? CGPoint(x: 0, y: 0), point: previousLocation)
        let curRadian = self.radianToCenterPoint(centerPoint: self.centerPoint ?? CGPoint(x: 0, y: 0), point: location)
        let changedRadian:CGFloat = curRadian - previousRadian
        self.changedRadian = changedRadian //记录
        self.rotateByRadian(radian: changedRadian)
        self.sendActions(for: .valueChanged)
        return true
    }
    
    /// 以ColorPanel的anchorPoint为坐标原点建立坐标系，计算坐标点|point|与坐标原点的连线距离x轴正方向的夹角
    /// - Parameters:
    ///   - centerPoint: 坐标原点坐标
    ///   - point: 某坐标点
    /// - Returns: 改变的值
    func radianToCenterPoint(centerPoint:CGPoint, point:CGPoint) -> CGFloat {
        let vector:CGVector = CGVector(dx: point.x - centerPoint.x, dy: point.y - centerPoint.y)
        return CGFloat(atan2f(Float(vector.dy), Float(vector.dx)))
    }
    
    /// 将图层旋转radian弧度
    /// - Parameter radian:  旋转的弧度
    func rotateByRadian(radian:CGFloat) {
        var transform = self.layer.affineTransform()
        transform = transform.rotated(by: radian)
        self.layer.setAffineTransform(transform)
    }

    
}
