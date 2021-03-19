//
//  Task.swift
//  taskapp
//
//  Created by takatoshi.ichige on 2021/03/16.
//

import RealmSwift

class Task: Object {
    
    @objc dynamic var id = 0
    
    @objc dynamic var title = ""
    
    @objc dynamic var contents = ""
    
    @objc dynamic var date = Date()
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getTitle() -> String {
        return title == "" ? title : "(タイトルなし)"
    }
    func getContents() -> String {
        return contents == "" ? contents : "(内容なし)"
    }
}
