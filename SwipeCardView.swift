//
//  SwipeCardView.swift
//  SwipeCardsView
//
//  Created by nathan on 11/11/2017.
//  Copyright © 2017 nathan. All rights reserved.
//

import UIKit

protocol CardDelegate : NSObjectProtocol
{
    func card(_ card : CardView, wasChosenWithDirection direction : SwipeDirection)
    func card(_ card : CardView, shouldChooseWithDirection direction : SwipeDirection) -> Bool
    func didRemoveCardFromContainer( _ card : CardView);
}
class CardView: UIView
{
    weak var delegate   : CardDelegate?
    
    var vLiked          : UIView?
    var vUnliked        : UIView?
    var options         : CardOptions!
    
    @IBOutlet weak var contentView : UIView!
    
    fileprivate var originalCenter : CGPoint
    {
        set
        {
            self.originalCenter = newValue;
        }
        get
        {
            if let sView = superview
            {
                return CGPoint(x: sView.width/2, y: sView.height/2);
            }
            return center;
        }
    }
    var originalFrame : CGRect?
    {
        didSet
        {
            self.frame = originalFrame!;
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder);
        options = CardOptions(threshold : UIScreen.main.bounds.size.width/2);
    }
    
    init(frame : CGRect, options : CardOptions)
    {
        super.init(frame: frame);
        self.options = options;
    }
    
    func CardSetup(_ options : CardOptions!)
    {
        self.options = options;
    }
    func swipeViewToDirection(_ direction : SwipeDirection)
    {
        guard
            let _ = delegate
        else
        {
            return;
        }
        let directionInt : CGFloat = direction == .Left ? -1.0 : 1.0;
        UIView.animate(withDuration: 0.2, animations:
            {
                let dx = UIScreen.main.bounds.width
                self.frame = self.frame.offsetBy(dx: dx * directionInt, dy: 0);
                self.transform = CGAffineTransform(rotationAngle: CGFloat(self.options.rotationAngle));
            }, completion: { [weak self] (completed) in
                if  let strongSelf = self,
                    strongSelf.delegate?.card(strongSelf, shouldChooseWithDirection: direction) == true
                {
                    strongSelf.removeCard(withDirection : direction);
                }
        }) 
    }
    func setupGesture()
    {
        let panG = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized(_:)));
        self.gestureRecognizers = [panG];
        self.isUserInteractionEnabled = true;
    }
    func panGestureRecognized(_ gesture : UIPanGestureRecognizer)
    {
        let translation = gesture.translation(in: self)
        if let view = gesture.view
        {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
            
            let transform = CGFloat(options.getRotationAngleForDX(view.center.x - originalCenter.x));
            view.transform = CGAffineTransform(rotationAngle: transform);
            contentView.backgroundColor = options.getBackgroundWithAlphaForDX(view.center.x - originalCenter.x);
        }
        gesture.setTranslation(CGPoint.zero, in: self)
        
        // user let go of card
        if gesture.state == .ended
        {
            let dx = center.x - originalCenter.x
            
            var destinationCenter = originalCenter;
            var destinationTransform = 0.0;
            var destinationColor = UIColor.white;
            
            // checks if whent through threshold
            let isOut = abs(dx) >= options.threshold;
            if isOut
            {
                let destX = dx > 0 ? UIScreen.main.bounds.size.width + self.frame.size.width : 0 - self.frame.size.width;
                destinationCenter = CGPoint(x: destX, y: originalCenter.y);
                destinationTransform = options.rotationAngle;
                destinationColor =  dx > 0 ? options.likeColor : options.unlikeColor;
            }
            UIView.animate(withDuration: 0.2,
                                       delay: 0,
                                       options: .curveEaseOut,
                                       animations:
                {
                    gesture.view!.transform = CGAffineTransform(rotationAngle: CGFloat(destinationTransform));
                    gesture.view!.frame = CGRect(x: 0, y: 0, width: gesture.view!.superview!.width, height: gesture.view!.superview!.height);
                    gesture.view!.center = destinationCenter;
                    self.contentView.backgroundColor = destinationColor;
                }, completion: {[unowned self] (completed) -> Void in
                    self.layoutIfNeeded();
                    if isOut
                    {
                        self.removeCard(withDirection : self.currentDirection());
                    }
            });
        }
    }
    fileprivate func removeCard(withDirection direction : SwipeDirection)
    {
        delegate?.card(self, wasChosenWithDirection: direction);
    }
    func currentDirection() -> SwipeDirection
    {
        let dx = center.x - originalCenter.x;
        if dx > 0
        {
            return .Right
        }
        else if dx < 0
        {
            return .Left
        }
        else
        {
            return .None
        }
    }
}
