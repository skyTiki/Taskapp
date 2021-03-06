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
    
    var categoryList = List<Category>()
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getTitle() -> String {
        return title == "" ?  "(タイトルなし)" : title
    }
    func getContents() -> String {
        return contents == "" ? "(内容なし)" : contents
    }
}
