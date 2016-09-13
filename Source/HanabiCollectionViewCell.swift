/**
 This file is part of the YBSlantedCollectionViewLayout package.
 
 Copyright (c) 2016 Yassir Barchi <dev.yassir@gmail.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit

/**
 YBSlantedCollectionViewCell is a subclass of UICollectionViewCell.
 Use it or subclass it to apply the slanting mask on your cells.
 */
public class HanabiCollectionViewCell: UICollectionViewCell {
    
    /// :nodoc:
    private var slantedLayerMask: CAShapeLayer?
    
    /// :nodoc:
    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        
        if (self.slantedLayerMask != nil) {
            let bezierPath = UIBezierPath()
            bezierPath.CGPath = self.slantedLayerMask!.path!
            let result = bezierPath.containsPoint(point)
            return result
        }
        
        return  (super.pointInside(point, withEvent: event))
    }
    
    /// :nodoc:
    override public func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        let attributes = layoutAttributes as! HanabiCollectionViewLayoutAttributes
        super.applyLayoutAttributes(attributes)
        self.slantedLayerMask = attributes.slantedLayerMask
        self.layer.mask = attributes.slantedLayerMask
    }
}

