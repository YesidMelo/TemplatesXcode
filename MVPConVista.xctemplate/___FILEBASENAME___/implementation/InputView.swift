//
//  InputView.swift
//  APSoft
//
//  Created by Yesid Melo on 4/2/19.
//  Copyright © 2019 Exsis. All rights reserved.
//

import UIKit
protocol InputViewDelegate{
    
}
class InputView: UIView {
    
    @IBOutlet var ContentView: UIView!
    private var parentContainer : UIView!
    
    private var myPresenter : IInputPresenter = InputPresenter()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        preload()
    }
    
    init(_ parent : UIView){
        parentContainer = parent
        super.init(frame: CGRect(x: 0, y: 0, width: parent.frame.width, height: parent.frame.height))
        preload()
    }
    
    private func preload(){
        registerXib()
        addInParent()
    }
    
    private func registerXib(){
        Bundle.main.loadNibNamed("InputView", owner: self, options: nil)
    }
    
    private func addInParent(){
        ContentView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        self.addSubview(ContentView)
        if !iHaveParentView() { return }
        parentContainer.addSubview(self)
    }
    
    private func iHaveParentView() -> Bool{
        return parentContainer != nil
    }
}
