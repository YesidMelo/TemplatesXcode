//
//  JSONParcer.swift
//  APSoft
//
//  Created by Yesid Melo on 6/19/19.
//  Copyright © 2019 Exsis. All rights reserved.
//

import Foundation


protocol DictionaryParcerCaster{ 
    init() 
}

class DictionaryParcer < T  : NSObject> {
    
    func convertFromDictionary(_ data : [ String : AnyObject ] , _ instance : T) {
        
        startInsertionInInstance(data,instance)
        
    }    
    
    private func startInsertionInInstance(_ json: [String: AnyObject],_ instance : T) {
        
        let aMirror = Mirror(reflecting: instance)
        var propertyAndTypes = [String : String]()
        getPropertiesAndType(aMirror,&propertyAndTypes)
        
        let customKeys : [String : String]? = (instance as! DictionaryParcerCaster).customKeysName()
        
        for item in propertyAndTypes{
            setValueInInstance(item,instance,customKeys,json)
        }
        
    }
    
    
    private func getPropertiesAndType(_ mirror : Mirror?,_ propertiesAndType : inout [String: String])  {
        if mirror == nil { return }
        
        for case let (label?, value) in mirror!.children {
            propertiesAndType[label] = "\(Mirror(reflecting: value).subjectType)".components(separatedBy: "<").last!.components(separatedBy: ">").first
        }
        
        getPropertiesAndType(mirror!.superclassMirror,&propertiesAndType)
    }
    
        
    
    private func setValueInInstance(_ labelType : (String,String),_ instance : T,_ customKeys : [String : String]?,_ data : [String : AnyObject]){
        
        let customKey = generateCustomKey(labelType,customKeys)
        let propertyValue = generatePropertyValue(customKey,data)
        
        if propertyValue == nil { return }
        
        let label = labelType.0
        let type  = labelType.1
        
        if isStringType(label,propertyValue!,instance) { return }
        if isNSNumberType(label,type,propertyValue!,instance) { return } 
        if isArray(label,type,propertyValue!,instance){ return }
        if isDictionaryGeneric(label,type,propertyValue!,instance) { return }
        if isDictionaryParcelable(label,type,propertyValue!,instance) { return } 
    }
    
    private func generateCustomKey(_ keyValue : (String,String),_ customKeys : [String:String]?) -> String{
        var key = keyValue.0
        
        if let custom = customKeys?[keyValue.0]{
            key = custom
        }
        
        return key
    }
    
    private func generatePropertyValue(_ key : String,_ data : [String : AnyObject]) -> AnyObject?{
        return data[key]
    }
    
    
    private func isStringType(_ attribute : String,_ propertyValue : AnyObject,_ instance : T) -> Bool {
        
        if let stringValue = propertyValue as? String {
            instance.setValue(stringValue, forKey: attribute)
            return true
        }
        
        return false
    }
    
    private func isNSNumberType(_ attribute : String,_ type : String,_ propertyValue : AnyObject,_ instance : T) -> Bool {
        
        if let intValue = propertyValue as? NSNumber {
            if type == "String"{
                instance.setValue(String(describing: intValue), forKey: attribute)
            } else {
                instance.setValue(intValue, forKey: attribute)
            }
            return true
        }
        
        return false
    }
    
    
    private func isArray(_ attribute : String,_ type : String,_ propertyValue: AnyObject,_ instance : T) -> Bool {
        
        if isArrayString(attribute,propertyValue,instance) { return true }
        if isArrayNSNumber(attribute,propertyValue,instance) { return true }
        if isArrayDictionary(attribute,type,propertyValue,instance) { return true }
        
        return false 
    }
    
    private func isArrayString(_ attribute : String,_ propertyValue: AnyObject,_ instance : T) -> Bool {
        
        if let arrayValue = propertyValue as? [String] {
            instance.setValue(arrayValue, forKey: attribute)
            return true
        }
        
        return false
    }
    
    private func isArrayNSNumber(_ attribute : String,_ propertyValue: AnyObject,_ instance : T) -> Bool {
        
        if let arrayValue = propertyValue as? [NSNumber] {
            instance.setValue(arrayValue, forKey: attribute)
            return true
        }
        
        return false
    }
    
    private func isArrayDictionary(_ attribute : String,_ type : String,_ propertyValue: AnyObject,_ instance : T) -> Bool {
        
        if let arrayValue = propertyValue as? [[String : AnyObject]] {
            
            var arrayObjects = [AnyObject]()
            
            for item in arrayValue {
                arrayObjects.append(generateObjectByArray(item,type))
            }
            
            instance.setValue(arrayObjects, forKey: attribute)
            
            return true
        }
        
        return false
    }
    
    private func generateObjectByArray(_ item : [String : AnyObject],_ type : String) -> AnyObject{
        let modelType : T.Type = swiftClassFromString(type)
        
        let instanceModel = modelType.init()
        
        do{
            
            try (instanceModel as! DictionaryParcerCaster).convertFromDictionary(item,instanceModel as NSObject) 
            return instanceModel
        } catch {
            
            print("Surgui un error generando arreglo de objeto")
            return instanceModel as AnyObject
        }      
        
    } 
    
    func swiftClassFromString(_ className: String) -> T.Type {
        
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
        var path = appName + "." + className
        
        if path.contains(" ") {
            path = path.replacingOccurrences(of: " ", with: "_", options: NSString.CompareOptions.literal, range: nil)
        }
        
        let anyClass: AnyClass = NSClassFromString(path)!
        
        return anyClass as! T.Type
    }
    
    private func isDictionaryGeneric(_ attribute : String,_ type : String,_ propertyValue: AnyObject,_ instance : T) -> Bool{
        if isDictionaryValid(type) {
            instance.setValue(propertyValue, forKey: attribute)
            return true
        }
        
        return false
    }
    
    private func isDictionaryValid(_ type : String) -> Bool{
        return type == "String, String" || type == "String, Int" || type == "String, Bool" || type == "Int, String"
    }
    
    private func isDictionaryParcelable(_ attribute : String,_ type : String,_ propertyValue: AnyObject,_ instance : T) -> Bool{
        if let modelValue = propertyValue as? [String:AnyObject] {
            
            let objectToInsert = generateObjectByArray(modelValue,type)
            instance.setValue(objectToInsert, forKey: attribute)
            
//            let modelType : ParcelableModel.Type = swiftClassFromString(type)
//            let modelObject = modelType.init()
//            modelObject.fromDictionary(modelValue)
            
            return true
        }
        
        return false
    }
    
    
    
    
    
    
    func convertFromArrayDictionary(_ data : [[ String : AnyObject ]] , _ instance : T) {
        print("")
    }
    
}


enum DictionaryParcerError : Error{
    case TypeInvalid
}

extension DictionaryParcerCaster {
    
    func convertFromDictionary<T : NSObject>(_ data : [ String : AnyObject ],_ object : T) throws {
        
        if object is DictionaryParcerCaster{
            
            let parcer = DictionaryParcer<T>()
            parcer.convertFromDictionary(data,object)
            return
            
        }
        
        throw DictionaryParcerError.TypeInvalid
        
        
    }
    
    func convertFromArrayDictionaries<T : NSObject> (_ data : [[ String : AnyObject ]],_ object : T) throws {
        
        if object is DictionaryParcerCaster{
            
            let parcer = DictionaryParcer<T>()
            parcer.convertFromArrayDictionary(data,object)
            return
            
        }
        
        throw DictionaryParcerError.TypeInvalid
        
    }
    
    public func customKeysName() -> [String : String]? {
        return nil
    }
}

