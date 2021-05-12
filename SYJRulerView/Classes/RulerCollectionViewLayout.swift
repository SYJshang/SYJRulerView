//
//  RulerCollectionViewLayout.swift
//  RulerKit
//
//  Created by SYJ on 2020/12/30.
//

import UIKit

class RulerCollectionViewLayout: UICollectionViewLayout {
    
    private var _spacing:CGFloat = 0.0     /**< cell间距  */
    var spacing:CGFloat {
        set {
            _spacing = newValue
            self.invalidateLayout()
        }
        get {
            return _spacing
        }
        
    }
    private var _itemSize:CGSize? = CGSize(width: 280, height: 400)
    var itemSize:CGSize? {
        set {
            if !__CGSizeEqualToSize(_itemSize!, newValue!) {
                _itemSize = newValue
                self.invalidateLayout()
            }

        }
        get {
           return _itemSize
        }
    }
    var actualLength:NSInteger = 0      /**< 数据的实际长度  */
    private var _offset:NSInteger = 0
    var offset:NSInteger {
        set {
            _offset = newValue
        }
        
        get {
            if _offset <= 0 {
                return 1
            }else {
                return _offset
            }
        }
    }
    private var _scrollDirection:UICollectionViewScrollDirection = UICollectionViewScrollDirection.horizontal     /**< 滑动方向  */
    var scrollDirection:UICollectionViewScrollDirection {
        set {
            if (_scrollDirection != newValue) {
                _scrollDirection = newValue
                self.invalidateLayout()
            }
        }
        
        get {
            return _scrollDirection
        }
        
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override public var collectionViewContentSize: CGSize {
        let total:NSInteger = self.collectionView?.numberOfItems(inSection: 0) ?? 0
        let loop:NSInteger = total / self.actualLength
        var extra:CGFloat = 0
        if (_scrollDirection == .horizontal) {
            extra = CGFloat((loop - 1)) * ((_itemSize!.width + _spacing) * 4 + _itemSize!.width / 2.0)
        } else {
            extra = CGFloat((loop - 1)) * ((_itemSize!.height + _spacing) * 4  + _itemSize!.height / 2.0)
        }
        let count:NSInteger = (self.collectionView?.numberOfItems(inSection: 0))!
        let width:CGFloat = (_scrollDirection == UICollectionViewScrollDirection.horizontal) ? CGFloat(count) * (_itemSize!.width + _spacing) - _spacing + extra : CGFloat((self.collectionView?.bounds.size.width)!)
        let height:CGFloat = (_scrollDirection == UICollectionViewScrollDirection.horizontal) ? CGFloat((self.collectionView?.bounds.size.height)!) : CGFloat(count) * (_itemSize!.height + _spacing) - _spacing + extra
        return CGSize(width: width, height: height)
    }
    
    /** 设置每个indexPath对应cell的Attribute */
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let loop:NSInteger = indexPath.row / self.actualLength
        let attribute:UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        attribute.size = _itemSize!
//        //每个循环最后一个cell的间距
        var extra:CGFloat = 0
        if _scrollDirection == .horizontal {
            extra = CGFloat(loop) * ((_itemSize!.width + _spacing) * 4  + _itemSize!.width / 2.0)
        } else {
            extra = CGFloat(loop) * ((_itemSize!.height + _spacing) * 4  + _itemSize!.height / 2.0)
        }
//        //x坐标 水平方向 = item总数 * (item宽度 + space) ; 垂直方向 = (collectionView - item宽度) / 2.0  (居中显示)
        let x:CGFloat = (_scrollDirection == UICollectionViewScrollDirection.horizontal) ? ((CGFloat(indexPath.item) * (_spacing + _itemSize!.width)) + extra) : (0.5 * ((self.collectionView?.bounds.size.width)! - _itemSize!.width))
//        //y坐标 水平方向 = (collectionView - item宽度) / 2.0 (居中显示) ; 垂直方向 = item总数 * (item高度 + space)
        let y:CGFloat = (_scrollDirection == UICollectionViewScrollDirection.horizontal) ? (0.5 * ((self.collectionView?.bounds.size.height)! - _itemSize!.height)) : (CGFloat(indexPath.item) * (_spacing + self.itemSize!.height)) + extra
//        //cell的实际frame
        attribute.frame = CGRect(x: x, y: y, width: attribute.size.width, height: attribute.size.height)
        return attribute;
    }
    
    /** 返回指定rect范围中所有cell的Attributes */
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = self.attributesInRect(rect: rect)
        return attributes as? [UICollectionViewLayoutAttributes]
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        //原本应该在屏幕中的rect
        let oldRect:CGRect = CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y, width: (self.collectionView?.bounds.size.width)!, height: (self.collectionView?.bounds.size.height)!)
        let elements = self.layoutAttributesForElements(in: oldRect)!
        let attributes:Array = elements
        //原本应该停留在collectionView中点的位置
        //水平方向中点位置 = 原本应该停留的x点 + collectionView一半宽
        //垂直方向中点位置 = 原本应该停留的y点 + collectionView一半高
        let center:CGFloat = (_scrollDirection == UICollectionViewScrollDirection.horizontal) ? (proposedContentOffset.x + 0.5 * (self.collectionView?.bounds.size.width)!) : (proposedContentOffset.y + 0.5 * (self.collectionView?.bounds.size.width)!)
        
        //找到距离collectionView中点位置最近的cell 并且计算他们之间的最小距离(minOffset)
        var minOffset:CGFloat = CGFloat(MAXFLOAT)
        for attribute in attributes {
            //判断当前是第几组
            let loopGroup:NSInteger = attribute.indexPath.item / self.actualLength
            if (attribute.indexPath.item % _offset == loopGroup % _offset) {
                let offset:CGFloat = (_scrollDirection == UICollectionViewScrollDirection.horizontal) ? (attribute.center.x - center) : (attribute.center.y - center)
                if abs(offset) < abs(minOffset) {
                    minOffset = offset
                }
            }
        }
        
        //所以最终应该停留的位置 = collectionView中点位置 + 与之距离最近cell的距离(minOffset) = 实际停留的cell位置
        let newX:CGFloat = (_scrollDirection == UICollectionViewScrollDirection.horizontal) ? (proposedContentOffset.x + minOffset) : proposedContentOffset.x
        let newY:CGFloat = (_scrollDirection == UICollectionViewScrollDirection.horizontal) ? proposedContentOffset.y : (proposedContentOffset.y + minOffset)
        return CGPoint(x: newX, y: newY)
    }
        
    func attributesInRect(rect: CGRect) -> NSArray {
        
        //计算额外组数
        //一轮循环的总偏移量
        var scaleWidth:CGFloat = 0.0
        var scrollLoop:NSInteger = 0
        
        if _scrollDirection == .horizontal {
            scaleWidth = _itemSize!.width
            let oneRoundOffset:CGFloat = ((scaleWidth + _spacing) * CGFloat(self.actualLength)) + ((scaleWidth + _spacing) * 4 + scaleWidth / 2.0)
            scrollLoop = NSInteger(rect.origin.x / oneRoundOffset)
        } else {
            scaleWidth = _itemSize!.height
            let oneRoundOffset:CGFloat = ((scaleWidth + self.spacing) * CGFloat(self.actualLength)) + ((scaleWidth + _spacing) * 4 + scaleWidth / 2.0)
            scrollLoop = NSInteger(rect.origin.y / oneRoundOffset)
        }
    
        let extra:CGFloat = CGFloat(scrollLoop) * ((scaleWidth + _spacing) * 4  + scaleWidth / 2.0)
        
        //指定范围内的第一个cell的下标
        var preIndex:NSInteger = (_scrollDirection == UICollectionViewScrollDirection.horizontal) ? NSInteger(((rect.origin.x - extra) / (_itemSize!.width + _spacing))) : NSInteger(((rect.origin.y - extra) / (_itemSize!.height + _spacing)))
        preIndex = ((preIndex < 0) ? 0 : preIndex)                        //防止下标越界

        //指定范围内的最后一个cell下标
        var latIndex:NSInteger = (_scrollDirection == UICollectionViewScrollDirection.horizontal) ? NSInteger(((rect.maxX - extra) / (_itemSize!.width + _spacing))) : NSInteger(((rect.maxY - extra) / (_itemSize!.height + _spacing)))
        let itemCount:NSInteger = (self.collectionView?.numberOfItems(inSection: 0))!
        latIndex = ((latIndex >= itemCount) ? itemCount - 1 : latIndex)      //防止下标越界

        var rectAttributes:Array<UICollectionViewLayoutAttributes> = []
        //将对应下标的attribute存入数组中
        for i in preIndex ... latIndex {
            let indexPath:NSIndexPath = NSIndexPath.init(item: i, section: 0)
            let attribute:UICollectionViewLayoutAttributes = self.layoutAttributesForItem(at: indexPath as IndexPath)!
            if rect.intersects(attribute.frame) {
                rectAttributes.append(attribute)
            }
            
        }
        return rectAttributes as NSArray
    }
    

}
