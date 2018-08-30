//
//  DBManger.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/16.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit
import FMDB



class DBManger: NSObject {
    
    
    var dbName = "mydb.sqlite"
    
    lazy var db:FMDatabase = {
        
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        
        let filePath = path?.appending("/" + self.dbName)
        let db = FMDatabase.init(path: filePath)
        return db
        
    }()
    
    
    
    //
    
    func openDB() {
        
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        
        let filePath = path?.appending("/"+dbName)
        db = FMDatabase.init(path: filePath)
        
        
        
        if db.open() == true  {
            
            print("打开成功")
        } else{
            print("打开失败")
        }
        
        
        let x = db.executeStatements(DBModel.sql1)
        let insert = try? db.executeUpdate(DBModel.sql2, withArgumentsIn: ["zhanshan","lishi"])
        let result = try? db.executeQuery(DBModel.sql3, values: nil)
        print(result)
        
    }
    
    private override init() {
        super.init()
    }
    static let manger:DBManger = {
        
        let instance = DBManger()
        return instance
    }()

}
