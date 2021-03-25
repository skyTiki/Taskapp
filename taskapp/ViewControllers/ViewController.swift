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
    
    let categoryListFirstIndexText = "<全カテゴリー>"
    
    // Realmのインスタンス作成
    let realm = try! Realm()
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    let categoryList = try! Realm().objects(Category.self)
    
    // 画面表示用のTaskの配列
    var filterdTaskArray: [Task]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //カテゴリ検索バーの初期値
        categorySearchTextField.text = categoryListFirstIndexText
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // カテゴリ検索バーの設定（カテゴリ新規追加に対応できるようviewWillAppearで定義）
        setupFilterdTextField()
        // タスク登録・更新されて戻ってきた場合に対応できるよう、テーブルを更新する。
        filterTaskReloadTableView()
        
       
    }
    
    private func filterTaskReloadTableView() {
        
        // カテゴリ検索バーが設定されていない、もしくは全カテゴリー以外の場合
        if categorySearchTextField.selectedIndex != nil && categorySearchTextField.selectedIndex != Optional(0) {
            let category: Category = Array(self.categoryList)[categorySearchTextField.selectedIndex! - 1]
            
            self.filterdTaskArray = Array(self.taskArray).filter({
                $0.categoryList.contains(category)
            })
        } else {
            // 全量Taskを入れる
            self.filterdTaskArray = Array(self.taskArray)
        }
        
        tableView.reloadData()
    }
    
    private func setupFilterdTextField() {
        
        // カテゴリ一覧の設定
        var categoryStringList: [String] {
            var stringList: [String] = [categoryListFirstIndexText]
            categoryList.forEach {
                stringList.append($0.name)
            }
            return stringList
        }
        categorySearchTextField.optionArray = categoryStringList
        
        // カテゴリーがタップされたときの挙動
        categorySearchTextField.didSelect { (text, index, id) in
            
            // 全カテゴリーが選ばれた場合
            if text == self.categoryListFirstIndexText {
                self.filterdTaskArray = Array(self.taskArray)
                self.tableView.reloadData()
                return
            }
            
            // 選択さてたカテゴリーを取得
            let category: Category = Array(self.categoryList).first(where: { $0.name == text })!
            // 該当のカテゴリーでフィルターする。（当てはまらないレコードを配列から削除）
            self.filterdTaskArray = Array(self.taskArray).filter({
                $0.categoryList.contains(category)
            })
            
            self.tableView.reloadData()
            
        }
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
    
    // 画面がスクロールされたらテキストボックスを閉じる
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

