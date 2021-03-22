//
//  Category.swift
//  taskapp
//
//  Created by takatoshi.ichige on 2021/03/19.
//

import RealmSwift

class Category: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
