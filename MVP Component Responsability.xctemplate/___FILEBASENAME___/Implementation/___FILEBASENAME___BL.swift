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
class ___VARIABLE_componentName___BL: BaseBL {
	
	// MARK: Properties
    
    override var listener: IBaseListener! {
        get {
            return super.listener as? I___VARIABLE_componentName___Listener
        }
        set {
            super.listener = newValue
        }
    }
    
    required init(baseListener: IBaseListener) {
        super.init(baseListener: baseListener)
    }
    
    required convenience init(listener: I___VARIABLE_componentName___Listener) {
        self.init(baseListener: listener)
    }
    
    func getListener() -> I___VARIABLE_componentName___Listener {
        return listener as! I___VARIABLE_componentName___Listener
    }
    
    // MARK: Listeners
}

// MARK: BL
extension ___VARIABLE_componentName___BL : I___VARIABLE_componentName___BL {
    
    // MARK: Actions
    
}