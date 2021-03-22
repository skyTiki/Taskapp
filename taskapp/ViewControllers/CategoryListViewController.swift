//
//  CategoryListViewController.swift
//  taskapp
//
//  Created by takatoshi.ichige on 2021/03/22.
//

import UIKit
import RealmSwift

class CategoryListViewController: UIViewController {

    @IBOutlet weak var categoryTableView: UITableView!
    
    // Realmから読み取り
    let realm = try! Realm()
    var categoryList: Results<Category>!
    
    // 設定されたCategoryを設定する
    var selectedCategoryList: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryList = realm.objects(Category.self)
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
    }
}

extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categoryList[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let selectedCategory: Category = categoryList.first(where: { $0.name == cell.textLabel?.text }) else { return }
        
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
            selectedCategoryList.append(selectedCategory)
        } else if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            selectedCategoryList.removeAll(where: { $0 == selectedCategory })
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        print(selectedCategoryList)
    }
    
}
