//
//  PopoverSelectorColor.swift
//  APSoft
//
//  Created by Yesid Melo on 5/30/19.
//  Copyright © 2019 Exsis. All rights reserved.
//

import UIKit

class PopoverSelectorColor: UIView {
    
    @IBOutlet var ContainerView: UIView!
    @IBOutlet weak var RedColor: PopoverColor!
    @IBOutlet weak var YellowColor: PopoverColor!
    @IBOutlet weak var GreenColor: PopoverColor!
    
    private var isOpenPopover = false
    private var parentView : PopoverColor!
    
    
    init(_ parentView : PopoverColor){
        super.init(frame: CGRect(x: 0, y: 0, width: 120, height: 45))
        self.parentView = parentView
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadNib()
    }
    
    private func loadNib(){
        Bundle.main.loadNibNamed("PopoverSelectorColor", owner: self, options: nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    func openPopover(){
        isOpenPopover = true
        registerInViewController()
    }
    
    private func registerInViewController(){
        print("Segundo punto de control")
        
        if parentView == nil { return }
        
        let myViewController = parentView.viewController()
        if myViewController == nil { return }
        
        loadNib()
        configColors()
        ContainerView.frame = frame
        frame.origin.y = generatePositionInViewController().origin.y
        frame.origin.x = generatePositionInViewController().origin.x
        addSubview(ContainerView)
        
        //locatePositionInViewController( parentView )
        myViewController?.view.addSubview(self)
        
        print("")
    }
    
    private func generatePositionInViewController() -> CGRect{
        if parentView.superview == nil {
            return frame
        }
        var finalPosition : CGRect = parentView.superview!.convert(parentView.frame, to: nil)
        finalPosition.origin.y = finalPosition.origin.y - parentView.frame.height - 5
        return finalPosition
    }
    
    private var profundidad = 1
    private var contadorProfundidad = 0
    private func locatePositionInViewController(_ view : UIView?){
        
        if contadorProfundidad == profundidad {
            print("He alcanzado el limite de la profundidad")
            return
        }
        
        if view == nil {
            print("La vista anterior no tiene padre")
            return 
        }
        comparePositionFromParent(view!,view!.superview)
        print("Profundidad : \(contadorProfundidad) limiteProfundidad : \(profundidad)")
        
        contadorProfundidad += 1
    }
    
    private func comparePositionFromParent(_ view : UIView,_ parent : UIView?){
        if parent == nil {
            print("Esta vista no tiene padre")
            return 
        }
        
        let posicionConvertida : CGRect = parent!.convert(view.frame, to: nil)
        print("la posision convertida es : \(posicionConvertida)")
    }
    
    private func configColors(){
        RedColor.iCanShowTheTooltip = false
        YellowColor.iCanShowTheTooltip = false
        GreenColor.iCanShowTheTooltip = false
        
        RedColor.setPopoverSelector(self)
        YellowColor.setPopoverSelector(self)
        GreenColor.setPopoverSelector(self)
        
        
    }
    
    
    func closePopover(_ colorSelected : UIColor){
        isOpenPopover = false
        parentView.defaultColor = colorSelected
        self.removeFromSuperview()
        
    }
    
    
    func isClosedPopover()->Bool{
        return !isOpenPopover
    }
    
}
