//
//  ViewController.swift
//  taskapp
//
//  Created by takatoshi.ichige on 2021/03/16.
//

import UIKit
import RealmSwift
import UserNotifications
import iOSDropDown

class ViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var categorySearchTextField: DropDown!
    
    // Realmのインスタンス作成
    let realm = try! Realm()
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    let categoryList = try! Realm().objects(Category.self)
    var filterdTaskArray: [Task]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        categorySearchTextField.text = "<全カテゴリー>"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.filterdTaskArray = Array(self.taskArray)
        
        if categorySearchTextField.selectedIndex != nil && categorySearchTextField.selectedIndex != Optional(0) {
            let category: Category = Array(self.categoryList)[categorySearchTextField.selectedIndex! - 1]
            
            self.filterdTaskArray.removeAll(where: {
                return !$0.categoryList.contains(category)
            })
        }
        
        // カテゴリテキストボックスの設定
        var categoryStringList: [String] {
            var stringList: [String] = ["<全カテゴリー>"]
            categoryList.forEach {
                stringList.append($0.name)
            }
            return stringList
        }
        categorySearchTextField.optionArray = categoryStringList
        categorySearchTextField.didSelect { (text, index, id) in
            self.filterdTaskArray = Array(self.taskArray)
            // 全選択が選ばれた場合
            if text == "<全カテゴリー>" {
                UIView.animate(withDuration: 0.2, animations: {
                    self.tableView.reloadData()
                })
                return
            }
            
            let category: Category = Array(self.categoryList).first(where: { $0.name == text })!

            self.filterdTaskArray.removeAll(where: {
                return !$0.categoryList.contains(category)
            })
            
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.reloadData()
            })
        }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = tableView.indexPathForSelectedRow
            inputViewController.task = filterdTaskArray[indexPath!.row]
        } else {
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        categorySearchTextField.endEditing(true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterdTaskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = filterdTaskArray[indexPath.row]
        
        cell.textLabel?.text = task.title
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        cell.detailTextLabel?.text = formatter.string(from: task.date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    // セルのモードを選択する。（削除モード、追加モード、設定なし）
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // 削除された時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = self.filterdTaskArray[indexPath.row]
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            try! realm.write{
                self.realm.delete(task)
                self.filterdTaskArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            // 未通知のローカル通知を出力
            center.getPendingNotificationRequests { requests in
                requests.forEach {
                    print("--削除後--")
                    print($0)
                    print("--------")
                }
            }
        }
    }
}

