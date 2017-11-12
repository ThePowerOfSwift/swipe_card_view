//
//  SwipeCardsContainer.swift
//  SwipeCardsView
//
//  Created by nathan on 11/11/2017.
//  Copyright © 2017 nathan. All rights reserved.
//

import UIKit

protocol Delegate : NSObjectProtocol
{
    func cardsView(_ cardsView : CardsContainer, didSwipeCard card : CardView , toDirection direction : SwipeDirection)
    func cardsView(_ cardsView : CardsContainer, shouldSwipeCard card : CardView , toDirection direction : SwipeDirection) -> Bool
    func cardsView(_ cardsView : CardsContainer, willEndDisplayingCard card : CardView, forIndex index : Int)
    func cardsView(_ cardsView : CardsContainer, removeCard card : CardView)
}
protocol DataSource : NSObjectProtocol
{
    func numberOfCards(inCardsContainer container : CardsContainer) -> Int
    func cardsView(_ container : CardsContainer, cardForIndex index : Int) -> CardView!
}

class CardsContainer: UIView , CardDelegate
{
    weak var dataSource  : DataSource? = nil
    weak var delegate    : Delegate? = nil
    
    func reloadData()
    {
        clearSubviews();
        guard
            let dSource = dataSource
            else
        {
            return;
        }
        
        let numberOfCards = dSource.numberOfCards(inCardsContainer: self)
        if numberOfCards == 0
        {
            return;
        }
        for index in 0..<numberOfCards
        {
            let card = dSource.cardsView(self, cardForIndex: index);
            card?.tag = index;
            card?.originalFrame = CGRect(x: 0, y: 0, width: width, height: height);
            card?.delegate = self;
            card?.setupGesture();
            self.insertSubview(card!, at: 0);
            self.layoutIfNeeded();
        }
    }
    fileprivate func clearSubviews()
    {
        UIView.setAnimationsEnabled(false);
        for subview in self.subviews
        {
            subview.removeFromSuperview();
        }
        UIView.setAnimationsEnabled(true);
    }
    func card(_ card: CardView, shouldChooseWithDirection direction: SwipeDirection) -> Bool
    {
        guard
            let should = delegate?.cardsView(self, shouldSwipeCard: card, toDirection: direction)
            else
        {
            return false
        }
        return should;
    }
    func card(_ card: CardView, wasChosenWithDirection direction: SwipeDirection)
    {
        delegate?.cardsView(self, didSwipeCard: card, toDirection: direction);
        card.removeFromSuperview();
    }
    func didRemoveCardFromContainer(_ card: CardView)
    {
        delegate?.cardsView(self, removeCard: card);
        card.removeFromSuperview();
    }
    
    override func willRemoveSubview(_ subview: UIView)
    {
        delegate?.cardsView(self, willEndDisplayingCard: subview as! CardView, forIndex: subview.tag);
    }
}
