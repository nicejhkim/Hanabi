//
//  HanabiCollectionViewLayout.swift
//  HanabiCollectionViewLayout
//
//  Created by Ivan Lisovyi on 21/11/2015.
//  Copyright © 2015 Ivan Lisovyi. All rights reserved.
//

import UIKit

@IBDesignable public class HanabiCollectionViewLayout: UICollectionViewLayout {
    @IBInspectable public var standartHeight: CGFloat = 220.0
    @IBInspectable public var focusedHeight: CGFloat = 380.0
    @IBInspectable public var dragOffset: CGFloat = 130.0
    @IBInspectable public var firstCellSlantingEnabled: Bool = false
    @IBInspectable public var lastCellSlantingEnabled: Bool = false
    @IBInspectable public var reverseSlantingAngle: Bool = false
    @IBInspectable public var slantingDelta: UInt = 70
    @IBInspectable public var lineSpacing: CGFloat = 0

    private var cachedLayoutAttributes = [UICollectionViewLayoutAttributes]()

    // MARK: UICollectionViewLayout

    internal var hasVerticalDirection: Bool {
        return true
    }
    
    override public func collectionViewContentSize() -> CGSize {
        guard let collectionView = collectionView else {
            return super.collectionViewContentSize()
        }
        
        let itemsCount = collectionView.numberOfItemsInSection(0)
        let contentHeight = CGFloat(itemsCount) * dragOffset + (collectionView.frame.height - dragOffset)
        
        return CGSize(width: collectionView.frame.width, height: contentHeight)
    }
    
    override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override public func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let proposedItemIndex = roundf(Float(proposedContentOffset.y / dragOffset))
        let nearestPageOffset = CGFloat(proposedItemIndex) * dragOffset
        
        return CGPoint(x: 0.0, y: nearestPageOffset)
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedLayoutAttributes.filter { attributes in
            return CGRectIntersectsRect(attributes.frame, rect)
        }
    }

    private func maskForItemAtIndexPath(indexPath: NSIndexPath, currentFocusedIndex: Int) -> CAShapeLayer {
        let slantedLayerMask = CAShapeLayer()
        let bezierPath = UIBezierPath()
        
        let disableSlantingForTheFirstCell = indexPath.row == 0 && !firstCellSlantingEnabled;
        
        let disableSlantingForTheFirstLastCell = indexPath.row == numberOfItems-1 && !lastCellSlantingEnabled;
        
        if ( hasVerticalDirection ) {
            if (reverseSlantingAngle) {
                bezierPath.moveToPoint(CGPoint.init(x: 0, y: 0))
                bezierPath.addLineToPoint(CGPoint.init(x: width, y: disableSlantingForTheFirstCell ? 0 : CGFloat(slantingDelta)))
                bezierPath.addLineToPoint(CGPoint.init(x: width, y: standartHeight))
                bezierPath.addLineToPoint(CGPoint.init(x: 0, y: disableSlantingForTheFirstLastCell ? standartHeight : standartHeight-CGFloat(slantingDelta)))
                bezierPath.addLineToPoint(CGPoint.init(x: 0, y: 0))
            }
            else {
                var height = standartHeight
                if currentFocusedIndex == indexPath.row || ( indexPath.item == (currentFocusedIndex+1) && indexPath.item != numberOfItems-1 ) {
                    height = focusedHeight
                }
//                indexPath.item == (currentFocusedIndex + 1) && indexPath.item != itemsCount
//                let height = currentFocusedIndex == indexPath.row ? focusedHeight : standartHeight
                let startPoint = CGPoint.init(x: 0, y: currentFocusedIndex == indexPath.row ? 0 : CGFloat(slantingDelta))
                bezierPath.moveToPoint(startPoint)
                bezierPath.addLineToPoint(CGPoint.init(x: width, y: 0))
                bezierPath.addLineToPoint(CGPoint.init(x: width, y: disableSlantingForTheFirstLastCell ? height : height-CGFloat(slantingDelta)))
                bezierPath.addLineToPoint(CGPoint.init(x: 0, y: height))
                bezierPath.addLineToPoint(startPoint)
            }
        }
        else {
            if (reverseSlantingAngle) {
                let startPoint = CGPoint.init(x: disableSlantingForTheFirstCell ? 0 : CGFloat(slantingDelta), y: 0)
                bezierPath.moveToPoint(startPoint)
                bezierPath.addLineToPoint(CGPoint.init(x: standartHeight, y: 0))
                bezierPath.addLineToPoint(CGPoint.init(x: disableSlantingForTheFirstLastCell ? standartHeight : standartHeight-CGFloat(slantingDelta), y: height))
                bezierPath.addLineToPoint(CGPoint.init(x: 0, y: height))
                bezierPath.addLineToPoint(startPoint)
            }
            else {
                bezierPath.moveToPoint(CGPoint.init(x: 0, y: 0))
                bezierPath.addLineToPoint(CGPoint.init(x: disableSlantingForTheFirstLastCell ? standartHeight : standartHeight-CGFloat(slantingDelta), y: 0))
                bezierPath.addLineToPoint(CGPoint.init(x: standartHeight, y: height))
                bezierPath.addLineToPoint(CGPoint.init(x: disableSlantingForTheFirstCell ? 0 : CGFloat(slantingDelta), y: height))
                bezierPath.addLineToPoint(CGPoint.init(x: 0, y: 0))
            }
        }
        
        bezierPath.closePath()
        
        slantedLayerMask.path = bezierPath.CGPath
        
        return slantedLayerMask
    }

    
    override public func prepareLayout() {
        guard let collectionView = collectionView else {
            return
        }
        
        cachedLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        let itemsCount = collectionView.numberOfItemsInSection(0)
        var frame = CGRectZero
        var y: CGFloat = 0.0
        
        for item in 0..<itemsCount {
            let indexPath = NSIndexPath(forItem: item, inSection: 0)
            
            var height = standartHeight
            let currentFocusedIndex = currentFocusedItemIndex()
            let nextItemOffset = nextItemPercentageOffset(forFocusedItemIndex: currentFocusedIndex)
            
            if indexPath.item == currentFocusedIndex {
                y = collectionView.contentOffset.y - standartHeight * nextItemOffset
                height = focusedHeight
            } else if indexPath.item == (currentFocusedIndex + 1) && indexPath.item != itemsCount {
                height = standartHeight + max((focusedHeight - standartHeight) * nextItemOffset, 0)
                y = y + standartHeight - height

            } else {
                y = frame.origin.y + frame.height + lineSpacing - CGFloat(slantingDelta)
            }
            //height = standartHeight
            
            frame = CGRect(x: 0, y: y, width: collectionView.frame.width, height: height)
            
            let attributes = HanabiCollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.zIndex = item
            attributes.frame = frame
            attributes.slantedLayerMask = self.maskForItemAtIndexPath(indexPath, currentFocusedIndex: currentFocusedIndex)
            
            cachedLayoutAttributes.append(attributes)
            
            //y = CGRectGetMaxY(frame) + lineSpacing - CGFloat(slantingDelta)
            y = y + height + lineSpacing - CGFloat(slantingDelta)
        }
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedLayoutAttributes[indexPath.item]
    }
    
    // MARK: Private methods
    
    private func currentFocusedItemIndex() -> Int {
        guard let collectionView = collectionView else {
            return 0
        }
        
        return max(0, Int(collectionView.contentOffset.y / dragOffset))
    }
    
    private func nextItemPercentageOffset(forFocusedItemIndex index: Int) -> CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        
        return (collectionView.contentOffset.y / dragOffset) - CGFloat(index)
    }
}

private extension UICollectionViewLayout {
    
    var numberOfItems: Int {
        return collectionView!.numberOfItemsInSection(0)
    }
    
    var width: CGFloat {
        return CGRectGetWidth(collectionView!.frame)-collectionView!.contentInset.left-collectionView!.contentInset.right
    }
    
    var height: CGFloat {
        return CGRectGetHeight(collectionView!.frame)-collectionView!.contentInset.top-collectionView!.contentInset.bottom
    }
}