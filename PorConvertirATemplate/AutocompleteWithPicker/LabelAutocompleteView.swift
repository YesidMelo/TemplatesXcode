//
//  LabelAutocompleteView.swift
//  APSoft
//
//  Created by Yesid Melo on 3/26/19.
//  Copyright © 2019 Exsis. All rights reserved.
//

import UIKit
//used this class in view if want show autocomplete text with picker
class LabelAutocompleteView: UIView {
    @IBOutlet var ContentView: UIView!
    @IBOutlet weak var LabelItemSelected: UILabel!
    @IBOutlet weak var ImageViewAdd: UIImageView!
    @IBOutlet weak var ImageViewForget: UIImageView!
    
    private var itemSelected : ItemsAutocompleteWithPicker!
    
    var dataSource : [ItemsAutocompleteWithPicker] = [ItemsAutocompleteWithPicker]()
    var funcDelegateAdd : ((ItemsAutocompleteWithPicker?)->Void)! 
    var funcDelegateFind : (()->Void)! = nil
    var itemDefault : ItemsAutocompleteWithPicker!{
        didSet{
            fillLabelWithItemDefault()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        preload()
    }
    
    private func  preload(){
        registerXib()
        addListeners()
        addViewInParent()
    }
    
    private func registerXib(){
        Bundle.main.loadNibNamed("LabelAutocompleteView", owner: self, options: nil)
    }
    
    private func addListeners(){
        enabledInteraction()
        addGestures()
    }
    
    private func enabledInteraction(){
        LabelItemSelected.isUserInteractionEnabled = true
        ImageViewAdd.isUserInteractionEnabled = true
        ImageViewForget.isUserInteractionEnabled = true
    }
    
    private func  addGestures(){
        let gestureLabelItemSelected = UITapGestureRecognizer(target: self, action: #selector(listeLabelItemSelected))
        let gestureImageViewAdd = UITapGestureRecognizer(target: self, action: #selector(listenImageViewAdd))
        let gestureImageViewForget = UITapGestureRecognizer(target: self, action: #selector(listenImageViewForget))
        
        LabelItemSelected.addGestureRecognizer(gestureLabelItemSelected)
        ImageViewAdd.addGestureRecognizer(gestureImageViewAdd)
        ImageViewForget.addGestureRecognizer(gestureImageViewForget)
    }
    
    @objc func listeLabelItemSelected(){
        showAutocompleteWithPicker()
        
    }
    
    private func showAutocompleteWithPicker(){
        _ = AutocompleteWithPicker(generateConfigViewAutocompletePicker())
    }
    
    
    
    private func generateConfigViewAutocompletePicker()->AutocompleteWithPicker.AutocompleteWithPickerDelegate{
        let config = AutocompleteWithPicker.AutocompleteWithPickerDelegate()
        config.viewContainer = self
        config.funcDelegate = listenSelectedOption
        config.dataSource = dataSource
        return config
    }
    
    private func listenSelectedOption(_ itemSelected : ItemsAutocompleteWithPicker?){
        if !iCanFillLabel(itemSelected) { return }
        LabelItemSelected.text = itemSelected!.getName()
        self.itemSelected = itemSelected
    }
    
    private func iCanFillLabel(_ itemSelected : ItemsAutocompleteWithPicker?)-> Bool{
        return itemSelected != nil
    }
    
    @objc func listenImageViewAdd(){
        LabelItemSelected.text = ""
        if let funcD = funcDelegateAdd{
            funcD(itemSelected)
            itemSelected = nil
            return 
        }
        print("LabelAutocompleteView: No ha ingresado funcDelegateAdd en ")
    }
    
    @objc func listenImageViewForget(){
        showAutocompleteWithPicker()
        if let funcD = funcDelegateFind {
            funcD()
            return 
        }
        print("LabelAutocompleteView: No ha ingresado funcDelegateFinc ")
    } 
   
    private func addViewInParent(){
        ContentView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        addSubview(ContentView)
    }
    
    private func fillLabelWithItemDefault(){
        if !iCanUpdateLabelWithItemDefault() { return }
        LabelItemSelected.text = itemDefault.getName()
    }
    
    private func iCanUpdateLabelWithItemDefault() -> Bool{
        return itemDefault != nil
    }
}
