//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//
//  MVP architecture pattern.
//

import Foundation

// MARK: Base
class ___VARIABLE_componentName___Presenter: BasePresenter {

	  // MARK: Properties

	  override var bl: IBaseBL! {
        get {
            return super.bl as? I___VARIABLE_componentName___BL
        }
        set {
            super.bl = newValue
        }
    }
    
    override var view: IBaseView! {
        get {
            return super.view as? I___VARIABLE_componentName___View
        }
        set {
            super.view = newValue
        }
    }
    
    required init(baseView: IBaseView) {
        super.init(baseView: baseView)
    }
    
    init(view: I___VARIABLE_componentName___View) {
        super.init(baseView: view)
        self.bl = ___VARIABLE_componentName___BL(listener: self)
    }
    
    fileprivate func getView() -> I___VARIABLE_componentName___View {
        return view as! I___VARIABLE_componentName___View
    }
    
    fileprivate func getBL() -> I___VARIABLE_componentName___BL {
        return bl as! I___VARIABLE_componentName___BL
    }
}

// MARK: Presenter
extension ___VARIABLE_componentName___Presenter: I___VARIABLE_componentName___Presenter {

    // MARK: Actions

}

// MARK: Listener
extension ___VARIABLE_componentName___Presenter: I___VARIABLE_componentName___Listener {

    // MARK: Listeners
    
}

