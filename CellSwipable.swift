//
//  CellSwipable.swift
//
//  Created by LaValse on 2016. 3. 17..
//  Copyright © 2016년 LaValse. All rights reserved.
//

import UIKit

enum SwipeDirection : String{
    case Left = "left", Right = "right"
};

class CellSwipable: UITableViewCell {
    var id : Int{
        get {
            return _id!
        }
        
        set{
            _id = newValue
            
            /*
            // Set Accessary Button
            
            btnShare?.tag = newValue
            btnDelete?.tag = newValue
            */
        }
    }
    
    private var _id : Int?
    private var gesture : UIPanGestureRecognizer?
    private let limitOffset : CGFloat = 150.0 // End of moving
    private var startX : CGFloat = 0.0 // Start x-axis
    private var centerPoint : CGFloat? // Center of its view
    private var dir : SwipeDirection? // Swipe Direction
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        gesture = UIPanGestureRecognizer(target: self, action: Selector("onSwipe:"))
        gesture?.delegate = self
        self.contentView.addGestureRecognizer(gesture!)
        
        /* Accessary View Initialize */
        self.insertSubview(ACCESSARY_VIEW, belowSubview: self.contentView)
        
        /* UI View Initialize(Views have to add on the "self.contentView") */
        self.contentView.addSubview(UIVIEW)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /* Set the view position like this in order to show when I swiped */
        ACCESSARY_VIEW.frame = CGRect(x: self.frame.width - limitOffset, y: 0, width: limitOffset, height: self.frame.height)
        
        /* Real point of center (self.contentView.center does not correct) */
        centerPoint = self.contentView.frame.size.width / 2.0
    }
    
    /* Swipe event */
    func onSwipe(recognizer: UIGestureRecognizer){
        let state = recognizer.state
        let p = recognizer.locationInView(self.contentView)
        
        let dist = startX - p.x
        dir = (dist < 0) ? SwipeDirection.Right : SwipeDirection.Left
        
        var tmpCenter = self.contentView.center
        tmpCenter.x -= dist
        tmpCenter.x = round(tmpCenter.x)
        
        let cDist = centerPoint! - tmpCenter.x
        
        var showedCenter = tmpCenter
        
        if dir == SwipeDirection.Left {
            if cDist >= limitOffset{
                tmpCenter.x = centerPoint! - limitOffset
            }
            
            showedCenter.x = tmpCenter.x - 30
        }else{
            if(cDist > 0){
                showedCenter = tmpCenter
            }else{
                showedCenter.x = centerPoint!
                
                if tmpCenter.x <= 0 {
                    tmpCenter.x = centerPoint! - limitOffset
                }
                
                if tmpCenter.x >= centerPoint! {
                    tmpCenter.x = centerPoint!
                }
            }
        }
        
        if state == UIGestureRecognizerState.Changed {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.contentView.center = showedCenter
            })
        }else{
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.contentView.center = tmpCenter
                },completion: { (Bool) -> Void in
                    let sp : CGFloat = self.limitOffset / 2
                    let closeDist : CGFloat = self.centerPoint! - sp
                    
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        tmpCenter.x = (tmpCenter.x > closeDist) ? self.centerPoint! : self.centerPoint! - self.limitOffset
                        self.contentView.center = tmpCenter
                    })
            })
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let p = gestureRecognizer.locationInView(self.contentView)
        
        startX = p.x
        
        return true
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /* Set a delegation of btns event included in ACCESSARY VIEW */
}
