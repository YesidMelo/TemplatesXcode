//
//  LabelDatePicker.swift
//  APSoft
//
//  Created by Yesid Melo on 4/25/19.
//  Copyright © 2019 Exsis. All rights reserved.
//

import UIKit

class LabelDatePicker: UIView {

    @IBOutlet var ContainerView: UIView!
    @IBOutlet weak var LabelDate: UILabel!
    @IBOutlet weak var ImageViewArrow: UIImageView!
    
    var delegate : ((Date)->Void)!
    var dateDefault : Date!{
        didSet{
            loadDateDefault()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        preload()
    }
    
    private func preload(){
        registerXib()
        addInParent()
        addListener()
    }
    
    private func registerXib(){
        Bundle.main.loadNibNamed("LabelDatePicker", owner: self, options: nil)
    }
    
    private func addInParent(){
        ContainerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        self.addSubview(ContainerView)
    }
    
    private func addListener(){
        enableInteractionUser()
        addGestures()
    }
    
    private func enableInteractionUser(){
        LabelDate.isUserInteractionEnabled = true
        ImageViewArrow.isUserInteractionEnabled = true
        ContainerView.isUserInteractionEnabled = true
    }
    
    private func addGestures(){
        let gestureLabelDate = UITapGestureRecognizer(target: self, action: #selector(listenLabelDate))
        let gestureImageViewArrow = UITapGestureRecognizer(target: self, action: #selector(listenImageViewArrow))
        
        LabelDate.addGestureRecognizer(gestureLabelDate)
        ImageViewArrow.addGestureRecognizer(gestureImageViewArrow)
    }
    
    @objc func listenLabelDate(){
        
        if !iCanSendDateToDelegate() { return }
        updateLabelDate()
        //showDatePickerGeneric()
    }
    
    private func updateLabelDate(){
        let myDate = Date()
        LabelDate.text = myDate.toString(withFormat: Constants.Formats.SLASH_DAY_MONTH_YEAR)
        delegate(myDate)
    }
    private func iCanSendDateToDelegate() -> Bool{
        return delegate != nil
    }
    
    private func showDatePickerGeneric(){
        let datePicker = DatePickerGeneric(self)
        datePicker.delegate = delegate
    }
    
    @objc func listenImageViewArrow(){
        if !iCanSendDateToDelegate() { return }
        updateLabelDate()
        //showDatePickerGeneric()
    }
    
    private func loadDateDefault(){
        if !iCanLabelWithDateDefault() { return }
        LabelDate.text = dateDefault.toString(withFormat: Constants.Formats.SLASH_DAY_MONTH_YEAR)
    }
    
    private func iCanLabelWithDateDefault() -> Bool{
        return dateDefault != nil
    }
}
