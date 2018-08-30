//
//  DBModel.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/16.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit

class DBModel: NSObject {

    
    static let sql1 = "create table if not exists my_person(" +
    "id integer primary key autoincrement," +
    "name text," +
    "age text" +
    ");"
    
    static let sql2 = "insert into my_person (name,age) values (?,?)"
    
    static let sql3 = "select *from my_person"
    

}
