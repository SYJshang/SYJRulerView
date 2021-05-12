//
//  RulerView.swift
//  RulerKit
//
//  Created by SYJ on 2020/12/30.
//

import UIKit

///返回一个颜色
public func RGBColor(r:Float , g:Float , b:Float) -> UIColor {
    return UIColor.init(red: (CGFloat(r/255.0)), green: (CGFloat(r/255.0)), blue: (CGFloat(r/255.0)), alpha: 1.0)
}

/// 16进制颜色转UIColor
public func HEXCOLOR(c: UInt64) -> (UIColor) {
    let redValue = CGFloat((c & 0xFF0000) >> 16)/255.0
    let greenValue = CGFloat((c & 0xFF00) >> 8)/255.0
    let blueValue = CGFloat(c & 0xFF)/255.0
    return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
}

public protocol RulerViewDelegate:NSObjectProtocol {
    
    /// 刻度尺选中值
    /// - Parameters:
    ///   - value: 值
    ///   - tag: 下标
    func rulerSelectValue(value: Double, tag: NSInteger)
    
}

public enum RulerNumberDirection {
    /** 水平方向：数字在上，刻度尺在下 */
    case numberTop
    /** 水平方向：数字在下，刻度尺在上 */
    case numberBottom
    /** 垂直方向：数字在左，刻度尺在右 */
    case numberLeft
    /** 垂直方向：数字在右，刻度尺在左  */
    case numberRight
}

public struct RulerrConfig {
    
    //视图属性
    /**< 短刻度长度  */
    public var shortScaleLength:CGFloat = 17.5
    /**< 长刻度长度  */
    public var longScaleLength:CGFloat = 25
    /**< 刻度尺宽度  */
    public var scaleWidth:CGFloat = 2
    /**< 短刻度起始位置  */
    public var shortScaleStart:CGFloat = 25
    /**< 长刻度起始位置  */
    public var longScaleStart:CGFloat = 25
    /**< 刻度之间的距离  */
    public var distanceBetweenScale:CGFloat = 8
    /**< 数字方向  */
    public var numberDirection:RulerNumberDirection = .numberBottom
    /**< 刻度和数字之间的距离  */
    public var distanceFromScaleToNumber:CGFloat = 35
    /**< 刻度颜色  */
    public var scaleColor:UIColor = HEXCOLOR(c: 0xdae0ed)

    //指示器
    /**< 指示视图宽高  */
    public var pointSize:CGSize = CGSize(width: 4, height: 40)
    /**< 指示视图颜色  */
    public var pointColor:UIColor = HEXCOLOR(c: 0x20c6ba)
    /**< 指示器视图起始位置  */
    public var pointStart:CGFloat = 20

    //数字属性
    /**< 数字字体  */
    public var numberFont:UIFont = UIFont.systemFont(ofSize: 11)
    /**< 数字颜色  */
    public var numberColor:UIColor = HEXCOLOR(c: 0x617272)

    //刻度相关
    /**< 最大值  */
    public var max:NSInteger = 20
    /**< 最小值  */
    public var min:NSInteger = 0
    /**< 默认值  */
    public var defaultNumber:Double = 10
    /**< 每次偏移的刻度尺单位  */
    public var offset:NSInteger = 1
    
    //选项
    /**< 保留一位小数类型  */
    public var isDecimal:Bool = true
    /**< 是否允许选中  */
    public var selectionEnable:Bool = true
    /**< 是否使用渐变色  */
    public var useGradient:Bool = true
    /**< 刻度尺反向  */
    public var reverse:Bool = false
    /**< 刻度尺循环  */
    public var infiniteLoop:Bool = true
    
    public init() {
        
    }
    
}

public class RulerView: UIView {

    /**< 代理  */
    public weak var delegate:RulerViewDelegate?
    /**< 属性设置  */
    public var rulerConfig:RulerrConfig?
    var rulerLayout:RulerCollectionViewLayout?
    /**< 刻度尺实际实现视图  */
    var rulerCollectionView:UICollectionView?
    /**< 指示器视图  */
    var indicatorView:UIImageView?
    //layer层，渐变layer
    var startGradientLayer:CAGradientLayer?
    var endGradientLayer:CAGradientLayer?
    /**< 当前选中的下标  */
    var selectIndex:NSInteger = 0
    /**< 下标数组  */
    var indexArray:Array<Any>? = []
    /**< 允许调用代理方法  */
    var activeDelegate:Bool = true
    /**< 当前滑动循环组  */
    var scrollLoop:NSInteger = 0

    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.rulerConfig = RulerrConfig()
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.layoutViews()
    }
    
    //MARK: - 视图布局
    func layoutViews() {
        //添加渐变层
        if (self.rulerConfig!.useGradient) {
            self.addStartGradientLayer()
            self.addEndGradientLayer()
        }
        
        //计算cell的size
        self.rulerLayout = RulerCollectionViewLayout()
        self.rulerLayout?.spacing = self.rulerConfig!.distanceBetweenScale
        self.rulerLayout?.offset = self.rulerConfig!.offset
        if self.rulerConfig!.numberDirection == .numberTop || self.rulerConfig!.numberDirection == .numberBottom {
            //水平方向
            self.rulerLayout?.scrollDirection = UICollectionViewScrollDirection.horizontal
            self.rulerLayout?.itemSize = CGSize(width: self.rulerConfig!.scaleWidth, height: self.frame.height)
        } else {
            //垂直方向
            self.rulerLayout?.scrollDirection = UICollectionViewScrollDirection.vertical
            self.rulerLayout?.itemSize = CGSize(width: (self.frame).width, height: self.rulerConfig!.scaleWidth)
        }
        
        self.rulerCollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: self.rulerLayout!)
        self.rulerCollectionView?.delegate = self
        self.rulerCollectionView?.dataSource = self
        self.rulerCollectionView?.showsVerticalScrollIndicator = false
        self.rulerCollectionView?.showsHorizontalScrollIndicator = false
        self.rulerCollectionView?.backgroundColor = UIColor.white.withAlphaComponent(0)
        self.rulerCollectionView?.register(RulerCollectionViewCell.self, forCellWithReuseIdentifier: RulerView.rulerCollectionViewCellIdentifier)

        //初始化数据
        self.initialData()
        //前后偏移
        self.rulerCollectionView?.contentInset = ((self.rulerLayout!.scrollDirection == UICollectionViewScrollDirection.horizontal) ? UIEdgeInsetsMake(0, self.frame.width / 2.0, 0, self.frame.width / 2.0) : UIEdgeInsetsMake(self.frame.height / 2.0, 0, self.frame.height / 2.0, 0))
        self.rulerCollectionView?.bounces = false
        self.addSubview(self.rulerCollectionView!)
        //指针
        self.indicatorView = UIImageView()
        self.centerPointView()
        self.indicatorView?.backgroundColor = self.rulerConfig!.pointColor
        self.indicatorView?.layer.cornerRadius = self.rulerConfig!.pointSize.width / 2.0
        self.addSubview(self.indicatorView!)
        //默认选中 偏移 = 指定数值 * (cell宽 + 刻度之间的距离) - 默认偏移 + cell宽的一半
        var offset:Double = 0
        //初始偏移值
        let contentInset:Double = ((self.rulerLayout!.scrollDirection == UICollectionViewScrollDirection.horizontal) ? Double(self.rulerCollectionView?.contentInset.left ?? 0) : Double(self.rulerCollectionView?.contentInset.top ?? 0))
        //默认选中值是否符合条件
        var suitableNumber = false
        //默认选中值有效才能调用偏移方法
        var activeSelectionNumber:Double = 0
        if (self.rulerConfig!.reverse) {
            activeSelectionNumber = Double(self.rulerConfig!.max) - self.rulerConfig!.defaultNumber
        } else {
            activeSelectionNumber = self.rulerConfig!.defaultNumber - Double(self.rulerConfig!.min)
        }
        if (activeSelectionNumber >= 0) {
            if (self.rulerConfig!.isDecimal) {
                //偏移计算：(单个刻度尺宽度 + 刻度尺间距) * 总刻度 - 起始偏移 + 最后一个刻度宽度 / 2.0
                offset = activeSelectionNumber * 10 * (Double(self.rulerConfig!.scaleWidth) + Double(self.rulerConfig!.distanceBetweenScale)) - contentInset + (Double(self.rulerConfig!.scaleWidth) / 2.0)
                //检测数字是否符合条件
                let defaultValue = String(format: "%.1f", activeSelectionNumber * 10)
                if (RulerView.isInt(str: defaultValue)) {
                    self.selectIndex = NSInteger(activeSelectionNumber * 10)
                    suitableNumber = true
                } else {
                    //偏移计算：(单个刻度尺宽度 + 刻度尺间距) * 总刻度 - 起始偏移 + 最后一个刻度宽度 / 2.0
                    offset = activeSelectionNumber * (Double(self.rulerConfig!.scaleWidth) + Double(self.rulerConfig!.distanceBetweenScale)) - contentInset + (Double(self.rulerConfig!.scaleWidth) / 2.0);
                    self.selectIndex = NSInteger(activeSelectionNumber)
                    suitableNumber = true
                }
            }
        }
        
        //如果没有默认值，就初始偏移
        if (offset == 0) {
            offset = -(contentInset - Double(self.rulerConfig!.scaleWidth) / 2.0)
        }
        //有效偏移才允许调用代理方法
        if (suitableNumber) {
            self.activeDelegate = true
        }
        
        //校正偏差
        self.correctionDeviation(offset: offset)
        //如果是循环尺
        if self.rulerConfig!.infiniteLoop {
            let totalCount:NSInteger = self.rulerCollectionView!.numberOfItems(inSection: 0)
            let factor:NSInteger = totalCount / self.rulerLayout!.actualLength / 2
            //一轮循环的总偏移量
            let oneRoundOffset:CGFloat = (CGFloat(self.rulerConfig!.scaleWidth) + CGFloat(self.rulerConfig!.distanceBetweenScale)) * CGFloat(self.rulerLayout!.actualLength) + ((CGFloat(self.rulerConfig!.scaleWidth) + CGFloat(self.rulerLayout!.spacing)) * 4 + CGFloat(self.rulerConfig!.scaleWidth) / 2.0)
            offset = offset + Double(factor) * Double(oneRoundOffset)
        }
        //此方法会触发scrollViewDidScroll
        self.rulerCollectionView?.contentOffset = ((self.rulerLayout!.scrollDirection == UICollectionViewScrollDirection.horizontal) ? CGPoint(x: offset, y: 0) : CGPoint(x: 0, y: offset))
        //默认选中(符号条件的才能默认选中)
        if (self.rulerConfig!.selectionEnable && suitableNumber) {
            self.rulerCollectionView?.layoutIfNeeded()
            self.selectCell()
        }
        self.activeDelegate = true
        
    }
    
    /** 指示视图居中 */
    func centerPointView() {
        if (self.rulerLayout!.scrollDirection == UICollectionViewScrollDirection.horizontal) {
            self.indicatorView?.frame = CGRect(x: (self.frame.width - self.rulerConfig!.pointSize.width) / 2.0, y: self.rulerConfig!.pointStart, width: self.rulerConfig!.pointSize.width, height: self.rulerConfig!.pointSize.height)
        } else {
            self.indicatorView?.frame = CGRect(x: self.rulerConfig!.pointStart, y: (self.frame.height - self.rulerConfig!.pointSize.width) / 2.0, width: self.rulerConfig!.pointSize.height, height: self.rulerConfig!.pointSize.width)
        }
    }
    
    /** 校正偏差 */
    func correctionDeviation(offset:Double) {
        //偏差校正说明：因为计算出来的偏移量会有小数，scrollview在设置偏移量时，会自动将小数偏移四舍五入
        //所以用指示视图的位置来校正这个偏差。当刻度尺开始滑动时，复原指示视图的位置
        let roundOffset:NSInteger = NSInteger(round(offset))
        let deviation:Double = offset - Double(roundOffset)
        if (self.rulerLayout!.scrollDirection == UICollectionViewScrollDirection.horizontal) {
            var frame = self.indicatorView?.frame
            frame?.origin.x += CGFloat(deviation)
            self.indicatorView?.frame = frame!
        } else {
            var frame = self.indicatorView?.frame
            frame?.origin.y += CGFloat(deviation)
            self.indicatorView?.frame = frame!
        }
    }
    
    /** 初始化数据 */
    func initialData() {
        //初始化数据源
        if (self.rulerConfig!.max == 0 || self.rulerConfig!.min >= self.rulerConfig!.max) {
            //校验数据
            return
        } else {
            self.indexArray?.removeAll()
            //因为是从0开始，所以需要在最大值基础上 + 1
            let items:NSInteger = self.rulerConfig!.max - self.rulerConfig!.min
            var totalCount:NSInteger = 0
            if self.rulerConfig!.isDecimal {
                //如果是一位小数类型，则数据扩大10倍
                totalCount = items * 10 + 1
            } else {
                totalCount = items + 1
            }
            
            //告诉layout数据的实际长度，以便计算每组数据之间的留白
            self.rulerLayout!.actualLength = totalCount
            var loopCount:NSInteger = totalCount
            if self.rulerConfig!.infiniteLoop {
                if (totalCount >= 1000 && totalCount <= 5000) {
                    loopCount = totalCount * 500
                } else if (totalCount < 1000) {
                    loopCount = totalCount * 1000
                } else {
                    if (totalCount * 100 < NSIntegerMax) {
                        loopCount = totalCount * 100
                    }
                }
            }
            for i in 0..<loopCount {
                self.indexArray?.append((i % totalCount))
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 代理方法
extension RulerView: UICollectionViewDelegate, UICollectionViewDataSource {

    private static let rulerCollectionViewCellIdentifier = "rulerCollectionViewCellIdentifier"

    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.indexArray?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:RulerCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: RulerView.rulerCollectionViewCellIdentifier, for: indexPath) as! RulerCollectionViewCell
        //计算下标
        let index:NSInteger = self.indexArray?[indexPath.row] as! NSInteger
        cell.index = index
        cell.rulerConfig = self.rulerConfig
        cell.setNeedsLayout()
        cell.makeCellHiddenText()
        return cell
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset:CGFloat = (self.rulerLayout?.scrollDirection == UICollectionViewScrollDirection.horizontal) ? (scrollView.contentOffset.x + self.rulerCollectionView!.contentInset.left) : (scrollView.contentOffset.y + self.rulerCollectionView!.contentInset.top)
        var index:NSInteger = 0
        if ((self.rulerConfig?.infiniteLoop) != false) {
            //一轮循环的总偏移量
            let oneRoundOffset:CGFloat = (self.rulerConfig!.scaleWidth + self.rulerConfig!.distanceBetweenScale) * CGFloat(self.rulerLayout!.actualLength) + (((CGFloat(self.rulerConfig!.scaleWidth)) + self.rulerLayout!.spacing) * 4 + self.rulerConfig!.scaleWidth / 2.0)
            if offset >= oneRoundOffset {
                self.scrollLoop = NSInteger(offset / oneRoundOffset)
            } else {
                self.scrollLoop = 0
            }
            offset = offset - (CGFloat(self.scrollLoop) * oneRoundOffset)
            index = NSInteger(round(offset / (self.rulerConfig!.scaleWidth + self.rulerConfig!.distanceBetweenScale)))
            self.selectIndex = index
        } else {
            index = NSInteger(round(offset / (self.rulerConfig!.scaleWidth + self.rulerConfig!.distanceBetweenScale)))
            self.selectIndex = index
        }
        
        var value:Double = 0
        //判断是否是小数
        if self.rulerConfig!.isDecimal {
            if self.rulerConfig!.reverse {
                value = Double(self.rulerConfig!.max) - (Double(index) * 1.0 / 10.0 + Double(self.rulerConfig!.min) + Double(self.rulerConfig!.min))
            } else {
                value = Double(index) * 1.0 / 10.0 + Double(self.rulerConfig!.min);
            }
        } else {
            if self.rulerConfig!.reverse {
                value = Double(self.rulerConfig!.max) - Double(index)
            } else {
                value = Double(index) * 1.0 + Double(self.rulerConfig!.min)
            }
        }
        //保证数据在范围内
        if value >= Double(self.rulerConfig!.min) && value <= Double(self.rulerConfig!.max) && self.activeDelegate {
            let str = String(format: "%.1f", value)
            let value2 = Double(str)
            self.delegate?.rulerSelectValue(value: value2 ?? 0, tag: self.tag)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.resetCell()
        //指示器视图居中显示
        self.centerPointView()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollToScrollStop:Bool = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if scrollToScrollStop {
            //定位到中间那组
            let totalCount:NSInteger = self.rulerCollectionView!.numberOfItems(inSection: 0)
            let factor:NSInteger = totalCount / self.rulerLayout!.actualLength / 2
            let indexOfLocation:NSInteger = self.selectIndex + factor * self.rulerLayout!.actualLength
            self.rulerCollectionView?.scrollToItem(at: NSIndexPath.init(row: indexOfLocation, section: 0) as IndexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
            //等视图更新完成才选中
            DispatchQueue.main.async {
                self.selectCell()
            }
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let dragToDragStop:Bool = scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
            if (dragToDragStop) {
                self.selectCell()
            }
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.selectCell()
    }
    
    ///选中cell
    func selectCell() {
        if self.rulerConfig!.selectionEnable {
            
            let min:NSInteger = self.selectIndex - 5
            let max:NSInteger = self.selectIndex + 5
            for i in min...max  {
                if i > 0 && (self.rulerLayout!.actualLength != 0) {
                    let hiddenIndex:NSInteger = i + self.scrollLoop * self.rulerLayout!.actualLength
                    let indexPath:IndexPath = IndexPath(row: hiddenIndex, section: 0)
                    let cell = self.rulerCollectionView?.cellForItem(at: indexPath) as! RulerCollectionViewCell?
                    cell?.makeCellHiddenText()
                }
            }
            
            let indexOfCell:NSInteger = self.selectIndex + self.scrollLoop * self.rulerLayout!.actualLength
            let cell = self.rulerCollectionView?.cellForItem(at: IndexPath(row: indexOfCell, section: 0)) as! RulerCollectionViewCell?
            cell?.makeCellSelect()
        }
    }
        
    ///重置cell
    func resetCell() {
        if self.rulerConfig!.selectionEnable {
            let min:NSInteger = self.selectIndex - 5
            let max:NSInteger = self.selectIndex + 5
            for i in min...max  {
                if i > 0 && (self.rulerLayout!.actualLength != 0) {
                    let index:NSInteger =  i + self.scrollLoop * self.rulerLayout!.actualLength
                    let cell = self.rulerCollectionView?.cellForItem(at: IndexPath(row: index, section: 0)) as! RulerCollectionViewCell?
                    cell?.setNeedsLayout()
                    cell?.layoutIfNeeded()

                }
            }
        }
    }
    
}

// MARK: - 通用方法
extension RulerView {
    //渐变透明层
    func addStartGradientLayer() {
        //初始化CAGradientlayer对象，使它的大小为UIView的大小
        self.startGradientLayer = CAGradientLayer()
        guard let startGradient = self.startGradientLayer else {
            print("self.startGradientLayer 没有初始化")
            return
        }
        startGradient.frame = self.bounds
        self.layer.addSublayer(startGradient)
        //设置渐变区域的起始和终止位置（颜色渐变范围为0-1）
        startGradient.startPoint = CGPoint(x: 0, y: 0)
        startGradient.endPoint = CGPoint(x: 1, y: 0)
        //设置颜色数组
        startGradient.colors = [UIColor.white.cgColor,UIColor.white.withAlphaComponent(0.0).cgColor]
        startGradient.locations = [0.0,0.3]
    }
    func addEndGradientLayer() {
        //初始化CAGradientlayer对象，使它的大小为UIView的大小
        self.endGradientLayer = CAGradientLayer()
        guard let endGradient = self.endGradientLayer else {
            print("self.endGradientLayer 没有初始化")
            return
        }
        endGradient.frame = self.bounds
        self.layer.addSublayer(endGradient)
        //设置渐变区域的起始和终止位置（颜色渐变范围为0-1）
        endGradient.startPoint = CGPoint(x: 0, y: 0)
        endGradient.endPoint = CGPoint(x: 1, y: 0)
        //设置颜色数组
        endGradient.colors = [UIColor.white.withAlphaComponent(0.0).cgColor,UIColor.white.cgColor]
        endGradient.locations = [0.7,1.0]
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



