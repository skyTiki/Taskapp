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
    @IBOutlet weak var categoryAddView: UIView!
    
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
    
    @IBAction func tappedSetCategory(_ sender: Any) {
        dismiss(animated: true, completion: {
            
        })
    }
    
    // カテゴリ追加ボタン　（アラート機能を使用してカテゴリ追加する）
    @IBAction func tappedAddCategory(_ sender: Any) {
        
        var alertTextField: UITextField?
        
        let alert = UIAlertController(title: "新規カテゴリ追加", message: "新規追加するカテゴリ名を入力してください。", preferredStyle: .alert)
        alert.addTextField { textField in
            alertTextField = textField
        }
        
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            if let categoryName = alertTextField?.text {
                let category: Category = .init()
                try! self.realm.write {
                    category.name = categoryName
                    if self.categoryList.count == 0 {
                        category.id = 0
                    } else {
                        category.id = self.categoryList.max(ofProperty: "id")! + 1
                    }
                    self.realm.add(category)
                    
                    self.categoryTableView.reloadData()
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
 
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = categoryList[indexPath.row]
            
            try! realm.write {
                realm.delete(category)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
}
