//
//  DBManagerSynchronization.swift
//  APSoft
//
//  Created by Yesid Melo on 5/28/19.
//  Copyright © 2019 Exsis. All rights reserved.
//

import Foundation
import SQLite3

class DBManagerSynchronization{
    
    private var listDetailSynchronized = [DetailSynchronized]()
    
    func synchronizeTables <T>(_ tables : [[T]],_ success : @escaping ()->Void,_ fail : @escaping () -> Void) where T : BaseModel{
        
            generateQueriesToExecute(tables)        
            executeQueries(
                {
                    self.finalizeSynchronizationTable({
                    success()
                    }, {
                        self.restoreTables(success, { print ("Error : No se restauro de forma adecuada la base de datos")})
                    fail()
                })
            },{
                self.restoreTables(
                    success, 
                    { 
                        print ("Error : No se restauro de forma adecuada la base de datos")}
                )
            })
        
    }
    
    private func generateQueriesToExecute <T>(_ tables: [[T]] ) where T : BaseModel{
        for table in tables {
            
            if table.isEmpty { continue }
            
            let detailSync = DetailSynchronized()
            generateTemporalTable(table[0],detailSync)
            generateQueryInsertTable(table,detailSync)
            listDetailSynchronized.append(detailSync)
        }
        
        
        
    }
    
    private func generateTemporalTable<T>(_ table : T,_ detailSync : DetailSynchronized) where T : BaseModel{
        detailSync.tableOriginal = generateNameTable(table)
        detailSync.tableTemp = "\(generateNameTable(table))_tmp"
    }
    
    private func generateNameTable <T: BaseModel>(_ table : T)-> String {
        let mirror = Mirror(reflecting: table)
        return " \(mirror.description)".replacingOccurrences(of: "Mirror for ", with: "")
    }
    
    private func generateQueryInsertTable<T : BaseModel>(_ listValues: [T],_ detailSync : DetailSynchronized) {
        var sentenseInsert = ""
        for item in listValues {
            sentenseInsert += generateSentenceInsertRecord(item,detailSync)
        }
        
        detailSync.insertValuesInTable = String(sentenseInsert.dropLast())
    }
    
    private func generateSentenceInsertRecord<T : BaseModel>(_ item : T,_ detailSync : DetailSynchronized) -> String {
        let columnsInDb = generateColumnsFromTableDB(item)
        
        var queryToExit = " insert or replace into \(detailSync.tableOriginal!) "
        let columns = generateColumnsToFill(item,columnsInDb)
        let values = generateValuesbyFill(item,columnsInDb)
        queryToExit += "( \(columns) ) values ( \(values) ); "
        
        return queryToExit
    }
    
    private func generateColumnsFromTableDB<T : BaseModel>(_ baseModel : T) -> [String]{
        let tableName = generateNameTable(baseModel)
        let Sentence = Constants.SqlStatements.PRAGMA_TABLE.replacingOccurrences(of: Constants.Keys.CHARSET, with: tableName)
        
        let db = getDatabase()
        
        let stament : OpaquePointer? = generateStamentPragma(db, Sentence)
        let columnsTable : [String] = generateColumnsTable(stament!)
        
        closeDatabase(db)
        
        return columnsTable
    }
    
    private func generateStamentPragma (_ db : OpaquePointer?,_ pragma :String?, _ failSave : (() -> Void)? = nil) -> OpaquePointer?{
        var newStament : OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, pragma, -1, &newStament, nil) != SQLITE_OK {
            
            DispatchQueue.main.async {
                failSave?()
            }
            
            closeDatabase(db)
            
            return nil
        }
        
        return newStament
    }
    
    private func generateColumnsTable (_ stament :OpaquePointer) -> [String]{
        var listColumns = [String]()
        while sqlite3_step(stament) == SQLITE_ROW {
            listColumns.append(String(cString: sqlite3_column_text(stament, 1)))
        }
        return listColumns
    }
    
    
    private func generateColumnsToFill<T : BaseModel>(_ item : T,_ columnsInTableDB : [String] )->String{
        var queryToExit = ""
        
        let mirror = Mirror(reflecting: item)
        callColumnsFromParent(&queryToExit,columnsInTableDB,mirror)
        
        queryToExit = String(queryToExit.dropLast())
        
        return queryToExit
    }
    
    private func callColumnsFromParent(_ queryToExit : inout String,_ columnsInTableDB : [String],_ mirror : Mirror?){
        if mirror == nil { return }
        
        if mirror!.subjectType == BaseModel.self as Any.Type
        {
            
            return 
        }
        
        for item in mirror!.children {
            
            for column in columnsInTableDB {
                if column != item.label{
                    continue 
                }
                queryToExit += clearStringOptional(" \(String(describing: item.label)),")
            }
            
        }
        
        callColumnsFromParent(&queryToExit,columnsInTableDB,mirror!.superclassMirror)
    }
    
    
    
   
    
    private func clearStringOptional(_ stringToClean : String)-> String{
        return stringToClean.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
    }
    
    private func generateValuesbyFill< T : BaseModel>(_ item : T,_ columnsInTableDB : [String])->String{
        let mirror = Mirror(reflecting: item)
        
        var valuesFromQuery = ""
        callValuesFromParent(item,&valuesFromQuery,columnsInTableDB,mirror)
        valuesFromQuery = String(valuesFromQuery.dropLast())
        
        return valuesFromQuery
    }
    
    private func callValuesFromParent<T : BaseModel>( _ obj : T,_ queryToExit : inout String,_ columnsInTableDB : [String],_ mirror : Mirror?){
        if mirror == nil { return }
        
        
        
        if mirror!.subjectType == BaseModel.self as Any.Type
        {
            return 
        }
        
        for item in mirror!.children {
            
            for column in columnsInTableDB {
                if column != item.label{
                    continue 
                }
                
                if case Optional<Any>.some(_) = item.value {
                    queryToExit += clearStringOptional("\(item.value),")
                }else{
                    queryToExit += clearStringOptional("null,")
                }
            }
            
        }
        
        let parent = mirror!.superclassMirror 
        callValuesFromParent(obj,&queryToExit,columnsInTableDB,parent)
    }
    
    
    
    private func executeQueries(_ success : @escaping ()->Void,_ fail : @escaping () -> Void){
        
        var sentenceToExecute : String = ""
        
        listDetailSynchronized.forEach{
            detailToSync in 
            
            sentenceToExecute += " \(generateQueryToExecute(detailToSync)) "
        }
        
        print("Sentencia : \n\n \(sentenceToExecute)")
        
        startSentenceInDB(sentenceToExecute,success,fail)
        
    }
    
    private func startSentenceInDB(_ sentence : String, _ success : @escaping () -> Void,_ fail : @escaping () -> Void){
        
        
        let database = getDatabase()
        
        if database == nil {
            fail()
            return 
        }
        
        if sqlite3_exec(database, sentence, nil, nil, nil) != SQLITE_OK{
            printErrorDatabase(database!)
            closeDatabase(database)
            fail()
            return
        }
        
        closeDatabase(database)
        success()
    }
    
    private func getDatabase() -> OpaquePointer?{
        var db : OpaquePointer? = nil
        sqlite3_open((databasePath() as NSString).utf8String, &db)
        return db
    }
    
    private func databasePath() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectory = paths[0] as NSString
        return documentDirectory.appendingPathComponent(Constants.SqlSettings.DB_PATH) as String
    }
    
    private func generateQueryToExecute(_ synchronizer : DetailSynchronized)-> String{
        return " \(synchronizer.createTableTemp!) \(synchronizer.clearTable!) \(synchronizer.insertValuesInTable!)"
    }
    
    private func printErrorDatabase(_ database : OpaquePointer){
        let error = String(cString: sqlite3_errmsg(database))
        print("Error : \(error)")
    }
    
    private func closeDatabase(_ database : OpaquePointer?){
        if database == nil { return }
        sqlite3_close(database)
    }
    
    private func finalizeSynchronizationTable(_ success : @escaping ()-> Void,_ fail : @escaping ()-> Void){
        startSentenceInDB(generateSentenceFinallyInsertSyncrhonizer(),success,fail)
    }
    
    private func generateSentenceFinallyInsertSyncrhonizer() -> String {
        var queryToExit = ""
        
        listDetailSynchronized.forEach{
            synchronizer in 
            queryToExit += synchronizer.dropTableTemp + " "
        }
        
        return queryToExit
    }
    
    
    
    
    private func restoreTables(_ success : @escaping ()-> Void,_ fail : @escaping ()-> Void ){
        startSentenceInDB(generateSentenseRestoreDB(), success, fail)
    }
    
    private func generateSentenseRestoreDB() -> String {
        var queryToExit = ""
        listDetailSynchronized.forEach{
            synchronized in 
            queryToExit += synchronized.clearTable + synchronized.revertTable + synchronized.dropTableTemp
        }
        return queryToExit
    }
 
    
    
    
    
    func cleanTables(_ tablesToClean : [BaseModel],_ success : @escaping () -> Void,_ fail :@escaping () -> Void){
        
        var listNameTables = [String]()
        
        tablesToClean.forEach{
            table in 
            
            listNameTables.append(generateNameTable(table))
            
        }
        
        let sentence = generateScriptClean(listNameTables)
        
        startSentenceInDB(sentence, success, fail)
        
    }
    
    private func generateScriptClean(_ listNameTables : [String]) -> String{
        
        var Sentence = ""
        
        listNameTables.forEach{
            nameTable in
            
            Sentence += "delete from \(nameTable);  "
            
        }
        
        return Sentence
    }
    
    
    private class DetailSynchronized{
        var tableOriginal : String!
        var tableTemp : String!{
            didSet {
                createTableTemp = "create temp table if not exists \(tableTemp!) as select * from \(tableOriginal!) ; "
                revertTable = "insert or replace into \(tableOriginal!) select * from \(tableTemp!) ; "
                dropTableTemp = "drop table if exists \(tableTemp!) ; "
                clearTable = "delete from \(tableOriginal!) ; "
            }
        }
        
        var createTableTemp : String!
        var revertTable : String!
        var dropTableTemp : String!
        var clearTable : String!
        var insertValuesInTable : String!
    }
}
