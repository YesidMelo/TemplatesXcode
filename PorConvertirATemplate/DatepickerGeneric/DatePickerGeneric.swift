//
//  DatePickerGeneric.swift
//  APSoft
//
//  Created by Yesid Melo on 4/25/19.
//  Copyright © 2019 Exsis. All rights reserved.
//

import UIKit


class DatePickerGeneric: UIView {

    @IBOutlet var ContainerView: UIView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var ButtonCancel: UIButton!
    @IBOutlet weak var ButtonOk: UIButton!
    @IBOutlet weak var ContainerButtons: UIView!
    @IBOutlet weak var ContainerDAtePicker: UIView!
    @IBOutlet weak var DateSelector: UIDatePicker!
    
    private var DateSelected : Date!
    var delegate : ((Date)->Void)!
    private var parentView : UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(_ parentContainer : UIView){
        self.parentView = parentContainer
        super.init(frame: CGRect(x: 0, y: 0, width: parentContainer.frame.width, height: parentContainer.frame.height))
        preload()
    }    
    
    private func preload(){
        registerXib()
        addListeners()
        disableInteractionUserParent()
        addView()
        style()
    }
    
    private func registerXib(){
        Bundle.main.loadNibNamed("DatePickerGeneric", owner: self, options: nil)
    }
    
    private func addListeners(){
        addGestureInButtonCancel()
        addGestureInButtonOk()
        
    }
    
    private func addGestureInButtonCancel(){
       let gestureButtonCancel = UITapGestureRecognizer(target: self, action: #selector(listenButtonCancel))
        gestureButtonCancel.delegate = self
        ButtonCancel.addGestureRecognizer(gestureButtonCancel)
    }
    
    @IBAction func listenButtonCancel(_ sender : Any){
        print("Button cancel")
    }
    
    private func addGestureInButtonOk(){
        let gestureButtonOk = UITapGestureRecognizer(target: self, action: #selector(listenButtonOk))
        gestureButtonOk.delegate = self
        
        ButtonOk.addGestureRecognizer(gestureButtonOk)
    }
    
    @objc func listenButtonOk(){
            
    }
    
    
    private func disableInteractionUserParent(){
        if !iCanAddInViewController(){ return }
        parentView.viewController()?.view!.isUserInteractionEnabled = false
        isUserInteractionEnabled = true
    }
    
    private func addView(){
        ContainerView.isUserInteractionEnabled = true
        if !iCanAddInViewController(){
            addViewWithoutViewController()
            return 
        }
        
        addinViewController()
    }
    
    private func iCanAddInViewController() -> Bool{
        return parentView != nil
    }
    
    private func addViewWithoutViewController(){        
        ContainerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        addSubview(ContainerView)
    }
    
    private func addinViewController(){
        let width : CGFloat = parentView.viewController()?.view.frame.width ?? 0
        let heigth : CGFloat = parentView.viewController()?.view.frame.height ?? 0
        ContainerView.frame = CGRect(x: 0, y: 0, width: width, height: heigth)
        self.addSubview(ContainerView)
        parentView.viewController()?.view!.addSubview(self)
        superview?.clipsToBounds = true
    }
    
    
    private func style(){
        background.blurImage()
    }
    
  
    
    
  
    
    private func enabledInteractionUserParent(){
        if !iCanAddInViewController(){ return }
        parentView.viewController()?.view!.isUserInteractionEnabled = true
        isUserInteractionEnabled = false
    }
    
    private func hiddenView(){
        removeFromSuperview()
    }
    
}

extension DatePickerGeneric : UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
