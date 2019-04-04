//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//
//  MVP architecture pattern.
//

import UIKit

protocol ___VARIABLE_componentName___ViewDelegate: BaseViewDelegate {
    
}

// MARK: Base
class ___VARIABLE_componentName___View: BaseView {

    // MARK: Outlets
    @IBOutlet var view: UIView!
  
  	// MARK: Properties

  	override var presenter: IBasePresenter! {
        get {
            return super.presenter as? I___VARIABLE_componentName___Presenter
        }
        set {
            super.presenter = newValue
        }
    }
    
    fileprivate func getPresenter() -> I___VARIABLE_componentName___Presenter {
        return presenter as! I___VARIABLE_componentName___Presenter
    }

    override var delegate: BaseViewDelegate! {
        get {
            return super.delegate as? ___VARIABLE_componentName___ViewDelegate
        }
        set {
            super.delegate = newValue
        }
    }

    fileprivate func getDelegate() -> ___VARIABLE_componentName___ViewDelegate {
        return delegate as! ___VARIABLE_componentName___ViewDelegate
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(delegate: ___VARIABLE_componentName___ViewDelegate) {
        super.init(frame: Constants.Sizes.SCREEN,
                   title: <#T##title: String##String#>,
                   delegate: delegate)
        presenter = ___VARIABLE_componentName___Presenter(view: self)

        Bundle.main.loadNibNamed("___VARIABLE_componentName___View",
                                 owner: self,
                                 options: nil)
        view.frame = frame
        self.addSubview(view)
    }

    // MARK: Actions
}

// MARK: View
extension ___VARIABLE_componentName___View : I___VARIABLE_componentName___View {
    
}