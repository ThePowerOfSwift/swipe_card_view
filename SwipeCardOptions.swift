//
//  SwipeCardsOptions.swift
//  SwipeCardsView
//
//  Created by nathan on 11/11/2017.
//  Copyright © 2017 nathan. All rights reserved.
//

import UIKit

public enum SwipeDirection : Int
{
    case Right = 0
    case Left = 1
    case None = 2
}

struct CardOptions
{
    var likeColor           : UIColor = ITECHColor.purple;
    var unlikeColor         : UIColor = ITECHColor.pink;
    var threshold           : CGFloat = UIScreen.main.bounds.width/2
    internal var rotationAngle       : Double = M_PI_4 / 8
    
    init(likeColor : UIColor, unlikeColor : UIColor, threshold : CGFloat)
    {
        self.likeColor = likeColor;
        self.unlikeColor = unlikeColor;
        self.threshold = threshold;
    }
    init(threshold : CGFloat)
    {
        self.threshold = threshold;
    }
    
    func getRotationAngleForDX(_ dx : CGFloat) -> Double
    {
        var part = dx / threshold;
        part = part > 1 ? 1 : part;
        return Double(part) * rotationAngle;
    }
    
    func getBackgroundWithAlphaForDX(_ dx : CGFloat) -> UIColor
    {
        var part = dx / threshold;
        part = part > 1 ? 1 : part < -1 ? -1 : part;
        if part > 0
        {
            return likeColor.withAlphaComponent(part/2);
        }
        else
        {
            return unlikeColor.withAlphaComponent(fabs(part/2));
        }
    }
}
