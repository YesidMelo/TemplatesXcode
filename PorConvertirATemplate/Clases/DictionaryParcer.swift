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
    func changeNameInAttribFromClass() -> [String:String]?
    
}

class DictionaryParcer < T  : NSObject> {
    
    func convertFromDictionary(_ data : [ String : AnyObject ] , _ instance : T) {
        
        startInsertionInInstance(data,instance)
        
    }    
    
    private func startInsertionInInstance(_ json: [String: AnyObject],_ instance : T) {
        
        let aMirror = Mirror(reflecting: instance)
        var propertyAndTypes = [String : String]()
        getPropertiesAndType(aMirror,&propertyAndTypes)
        
        let customKeys : [String : String]? = (instance as! DictionaryParcerCaster).changeNameInAttribFromClass()
        
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
                let objectCreated = generateObjectByArray(item,type)                
                arrayObjects.append(objectCreated)
            }
            
            instance.setValue(arrayObjects, forKey: attribute)
            
            return true
        }
        
        return false
    }
    
    private func generateObjectByArray<K : NSObject>(_ item : [String : AnyObject],_ type : String) -> K{
        let modelType : K.Type = swiftClassFromString(type) as! K.Type
        
        let instanceModel = modelType.init()
        
        do{
            
            try (instanceModel as! DictionaryParcerCaster).convertFromDictionary(item,instanceModel as NSObject) 
            return instanceModel
        } catch {
            
            print("Surgui un error generando arreglo de objeto")
            return instanceModel 
        }      
        
    } 
    
    func swiftClassFromString<K : NSObject>(_ className: String) -> K.Type {
        
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
        var path = appName + "." + className
        
        if path.contains(" ") {
            path = path.replacingOccurrences(of: " ", with: "_", options: NSString.CompareOptions.literal, range: nil)
        }
        
        let anyClass: AnyClass = NSClassFromString(path)!
        
        return anyClass as! K.Type
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
            
            return true
        }
        
        return false
    }
    
    
    
    func convertFromArrayDictionary(_ data : [[ String : AnyObject ]] , _ instance : T) -> [T]{
        
        var arrayObjects = [T]()
        
        data.forEach{
            item in 
            
            let copyInstance = T.init()
            startInsertionInInstance(item,copyInstance )
            arrayObjects.append(copyInstance)
            
        }
        
        return arrayObjects
    }
    
    
    
    
    
    
    public func convertToDictionary(_ object : T) -> [String: AnyObject] {
        
        var dictionary = Dictionary<String, AnyObject>()
        
        var propertyAndTypes = [String : String]()
        let mirror = Mirror(reflecting: object)
        
        getPropertiesAndType(mirror,&propertyAndTypes)
        
        for (label, _) in propertyAndTypes {
            
            fillDictionary(&dictionary,object,label)
            
        }
        
        return dictionary
    }
    
    
    private func fillDictionary(_ dictionary : inout Dictionary<String, AnyObject>,_ object : T,_ label : String){
        
        guard let propertyValue = object.value(forKey: label) else {
            return
        }
        
        if propertyValue is String
        {
            dictionary[label] = propertyValue as! String as AnyObject?
            return 
        }
        
        if propertyValue is NSNumber
        {
            dictionary[label] = propertyValue as! NSNumber
            return 
        }
        
        if propertyValue is Array<String>
        {
            dictionary[label] = propertyValue as AnyObject?
            return 
        }
        
        if propertyValue is Array<AnyObject>
        {
            let tmo = propertyValue as? Array<AnyObject>
            var array = Array<[String: AnyObject]>()
            
            for item in (propertyValue as! Array<DictionaryParcerCaster>) {
                do {
                    let dictionaryLocal = try (item as! DictionaryParcerCaster).convertToDictionary(item as! NSObject)
                    array.append(dictionaryLocal)
                }catch {
                    print("Error : fallo casteo de un item")
                }
            }
            
            dictionary[label] = array as AnyObject?
            return 
        }
        
        if propertyValue is NSDictionary
        {
            dictionary[label] = propertyValue as AnyObject?
            return 
        }
        // AnyObject
        do {
            dictionary[label] = try (propertyValue as! DictionaryParcerCaster).convertToDictionary(propertyValue as! NSObject) as AnyObject
        }catch {
            print("Error :  fallo el casteo de un any object")
        }
        
        
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
    
    func convertFromArrayDictionaries<T : NSObject> (_ data : [[ String : AnyObject ]],_ object : T) throws -> [T]{
        
        if object is DictionaryParcerCaster{
            
            let parcer = DictionaryParcer<T>()
            return parcer.convertFromArrayDictionary(data,object)
            
        }
        
        throw DictionaryParcerError.TypeInvalid
        
    }
    
    func convertToDictionary<T : NSObject>(_ object : T) throws -> [String : AnyObject] {
        
        if !(object is DictionaryParcerCaster){
            throw DictionaryParcerError.TypeInvalid 
        }
        
        let parcer = DictionaryParcer<T>()
        return parcer.convertToDictionary(object)
    }
}

