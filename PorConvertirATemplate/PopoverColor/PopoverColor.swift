//
//  PopoverColor.swift
//  APSoft
//
//  Created by Yesid Melo on 5/30/19.
//  Copyright © 2019 Exsis. All rights reserved.
//

import UIKit

@IBDesignable
class PopoverColor: UIView {
    
    @IBInspectable var defaultColor : UIColor = UIColor.red{
        didSet{
            self.layer.backgroundColor = self.defaultColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius : CGFloat = 15 {
        didSet{
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    var funcDelegateColor : ((UIColor)->Void)!
    
    @IBInspectable var iCanShowTheTooltip :Bool = false
    
    private var popOver : PopoverSelectorColor!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadNib()
        preloadView()
    }
    
    private func loadNib(){
        Bundle.main.loadNibNamed("PopoverColor", owner: self, options: nil)
    }
    
    
    
    
//    Start code by test
    
    
    private func preloadView(){
        addListeners() // ok 
        convertmeToCircle()
        createPopover()
    }
    
    private func addListeners(){
        let gestureFromView = UITapGestureRecognizer(target: self, action: #selector(listenTouch))
        gestureFromView.cancelsTouchesInView = false
        addGestureRecognizer(gestureFromView)
    }
    
    @objc func listenTouch(){        
        if !iCanShowTheTooltip {
            print("No soy disparador de tooltip")
            popOver.closePopover(defaultColor)
            return 
        }
        
       print("Soy disparador Tooltip")
        showPopoverColor()
    }
    
    private func showPopoverColor(){
        createPopover()
        popOver.openPopover()
    }
    
    
    
    private func createPopover(){
        if popOver != nil { return }
        if !iCanShowTheTooltip { return }
        popOver = PopoverSelectorColor(self)
    }
    
    
    private func convertmeToCircle(){
        self.layer.cornerRadius = self.frame.height / 2 
    }
    
    func setPopoverSelector(_ popoverSelector : PopoverSelectorColor){
        self.popOver = popoverSelector
    }
    
    func closePopover(){
        if popOver == nil  { return }
        popOver.closePopover(defaultColor)
    }
    
    
}
