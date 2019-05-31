//
//  AutocompleteWithPicker.swift
//  APSoft
//
//  Created by Yesid Melo on 3/20/19.
//  Copyright © 2019 Exsis. All rights reserved.
//

import UIKit
protocol ItemsAutocompleteWithPicker {
    func getId()->NSNumber
    func getName()->String
}

//Important Used LabelAutocempleteview by used this component in your view
class AutocompleteWithPicker: UIView {
    
    @IBOutlet var ContainerView: UIView!
    @IBOutlet weak var FilterOptiond: UITextField!
    @IBOutlet weak var SuggestionsPicker: UIPickerView!
    @IBOutlet weak var ImageBlur: UIImageView!
    
    @IBOutlet weak var HeigthPicker: NSLayoutConstraint!
    
    var delegate : AutocompleteWithPickerDelegate!{
        didSet{
            dataSource = delegate.dataSource
        }
    }
    
    var dataSource : [ItemsAutocompleteWithPicker]! = [ItemsAutocompleteWithPicker]()
    
    private var userInput: String? = nil {
        didSet{
            if userInput == nil { return }
            startFilter()
        }
    }
    
    
    private var  suggestions = [ItemsAutocompleteWithPicker]()
    private var  itemSelected: ItemsAutocompleteWithPicker?
    private var originalHeigthPicker :CGFloat!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        generateValuesByTest()
        preload()
    }
    
    private func generateValuesByTest(){
        class tmp : ItemsAutocompleteWithPicker{
            var Id :NSNumber!
            var Name : String!
            init(_ id: NSNumber, _ name : String){
                self.Id = id
                self.Name = name
            }
            func getId() -> NSNumber {
                return Id
            }
            
            func getName() -> String {
                return Name
            }
            
            
        }
        
        dataSource = [tmp(1,"Malo"),tmp(2,"Melo"),tmp(3,"Milo"),tmp(4,"Mola"),tmp(5,"Mula"),tmp(6,"Malito"),tmp(6,"Malote"),tmp(6,"Maleta")]
    }
    
    private func preload(){
        addDataSource()
        registerXib()
        captureOriginalHeigth()
        hiddenPicker()
        addListeners()
        addListenerTapPicker()
        addViewInParent()
    }
    
    
    private func addDataSource(){
        if !iCanSetDatasource() { return }
        dataSource = self.delegate.dataSource
    }
    
    private func iCanSetDatasource() -> Bool{
        return delegate != nil
    }
    
    private func registerXib(){
        Bundle.main.loadNibNamed("AutocompleteWithPicker", owner: self, options: nil)
        setStyle()
    }
    
    private func setStyle(){
        ImageBlur.blurImage()
    }
    
    private func captureOriginalHeigth(){
        originalHeigthPicker = HeigthPicker.constant
    }
    private func hiddenPicker(){
        SuggestionsPicker.isHidden = true
        HeigthPicker.constant = CGFloat(0)
    }
    
    private func addListeners(){
        enableInteractionUser()
        addGesturePad()
    }
    
    private func enableInteractionUser(){
        ImageBlur.isUserInteractionEnabled = true
    }
    
    private func addGesturePad(){
        let gestureImageBlur = UITapGestureRecognizer(target: self, action: #selector(listenerImageBlur))
        
        ImageBlur.addGestureRecognizer(gestureImageBlur)
    }
    
    @objc func listenerImageBlur(){
        quitAutocomplete()
    }
    
    private func quitAutocomplete(){
        hiddenPicker()
        FilterOptiond.text = ""
        hiddenAutocomplete() 
    }
    
    private func addListenerTapPicker(){
        let tapPicker = UITapGestureRecognizer(target: self, action: #selector(listenTapPicker))
        tapPicker.delegate = self
        self.SuggestionsPicker.addGestureRecognizer(tapPicker)
    }
    
    @objc func listenTapPicker(_ tapRecognizer : UITapGestureRecognizer){
        if tapRecognizer.state == .ended{
            let rowHeight = self.SuggestionsPicker.rowSize(forComponent: 0).height
            let selectedRowFrame = self.SuggestionsPicker.bounds.insetBy(dx: 0, dy: (self.SuggestionsPicker.frame.height - rowHeight) / 2)
            let userTappedOnSelectedRow = selectedRowFrame.contains(tapRecognizer.location(in: self.SuggestionsPicker))
            if userTappedOnSelectedRow {
                let selectedRow = self.SuggestionsPicker.selectedRow(inComponent: 0)
                fixedOptionSelectedInTextField(selectedRow)
                hiddenPicker()
                hiddenAutocomplete()
                delegate.funcDelegate(itemSelected)
            } 
        }
    }
    
    private func fixedOptionSelectedInTextField(_ selectedRow : Int){
        if suggestions.isEmpty{
            return
        }
        itemSelected = suggestions[selectedRow]
        FilterOptiond.text = itemSelected!.getName()
    }
    
    func hiddenAutocomplete(){
        removeFromSuperview()
    }
    
    private func addViewInParent(){
        ContainerView.frame = frame
        self.addSubview(ContainerView)
        self.delegate.viewContainer.viewController()!.view!.addSubview(self)
    }
    
     
    private func iCanSetViewInViewController()->Bool{
        return delegate != nil && delegate.myViewController != nil
    }
    

    private func iCanSetViewInViewFromViewController() -> Bool {
        return delegate != nil && delegate.viewContainer != nil && delegate.viewContainer.viewController() != nil
    }
    
    private func showPicker(){
        SuggestionsPicker.isHidden = false
        HeigthPicker.constant = originalHeigthPicker
    }
    
    func getItemSelected()-> ItemsAutocompleteWithPicker?{
        return self.itemSelected
    }
    
    private func startFilter(){
        let timeDelay = DispatchTime(uptimeNanoseconds: UInt64(100))
        
        DispatchQueue.global(qos : .background ).asyncAfter(deadline: timeDelay){
            
            
            if !self.iCanStartFilter(self.userInput!){
                self.suggestions = [ItemsAutocompleteWithPicker]()
                self.reloadSuggestions()
                return
            }
            self.suggestions = self.generateSuggestions(self.userInput ?? "")
            self.reloadSuggestions()
        }
    }
    
    init(_ delegate : AutocompleteWithPickerDelegate){
        let width = delegate.viewContainer.viewController()!.view.frame.width
        let heigth = delegate.viewContainer.viewController()!.view.frame.height 
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: heigth))
        self.delegate = delegate
        preload()
    }
    
    
    
    class AutocompleteWithPickerDelegate{
        var myViewController : UIViewController!
        var viewContainer : UIView!
        var funcDelegate : ((ItemsAutocompleteWithPicker?)->Void)!
        var dataSource : [ItemsAutocompleteWithPicker]!
    }
    
    
    
    
    
}

extension AutocompleteWithPicker : UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { //1
        userInput = self.FilterOptiond.text ?? ""
        return true
    }
    
    
    private func iCanStartFilter(_ userInput : String)->Bool{
        return !userInput.isEmpty
    }
    
    private func generateSuggestions(_ userInput : String) -> [ItemsAutocompleteWithPicker]{
        //return dataSource.filter{$0.getName().lowercased().contains(userInput.lowercased())}
        return dataSource.filter{
            return detailFilter($0,userInput)
        }
    }
    
    private func detailFilter(_ itemData : ItemsAutocompleteWithPicker,_ userInput: String)->Bool{
        let subString = String(itemData.getName().prefix(userInput.count)).lowercased()
        return subString.contains(userInput.lowercased())
    }
    
    private func reloadSuggestions(){
        DispatchQueue.main.async {
            self.SuggestionsPicker.reloadAllComponents()
            if self.suggestions.isEmpty {
                self.hiddenPicker()
                return 
            }
            self.SuggestionsPicker.selectedRow(inComponent: 0)
            self.showPicker()
        }
    }
}
extension AutocompleteWithPicker : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.suggestions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.suggestions[row].getName()
    }
    
}
extension AutocompleteWithPicker : UIPickerViewDelegate{
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if suggestions.isEmpty {
            itemSelected = nil
            return
        }
        self.itemSelected = self.suggestions[row]
    }
    
    
}

extension AutocompleteWithPicker : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

