//
//  InputViewController.swift
//  taskapp
//
//  Created by takatoshi.ichige on 2021/03/16.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    
    
    @IBOutlet weak var taskStatusSegmentControl: UISegmentedControl!
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryStackView: UIStackView!
    
    var task: Task!
    var categoryList: [Category]? {
        // カテゴリ一覧画面から選択された内容を画面に反映させる
        didSet {
            if let categoryList = categoryList {
                
                // StackViewの中身を空にする
                categoryStackView.subviews.forEach {
                    $0.removeFromSuperview()
                }
                // StackViewに値を設定
                categoryList.forEach({ category in
                    let label: UILabel = .init()
                    label.text = category.name
                    label.backgroundColor = .init(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1)
                    label.layer.cornerRadius = 1
                    label.clipsToBounds = true
                    
                    
                    categoryStackView.addArrangedSubview(label)
                })
                
                // 左寄せにするため２つ空のViewを挿入する
                for _ in 1...2 {
                    let view = UIView()
                    categoryStackView.addArrangedSubview(view)
                }
            }
        }
    }
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture: UITapGestureRecognizer = .init(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setTaskData()
        modifyUI()
        
    }
    
    private func setTaskData() {
        textField.text = task.title
        textView.text = task.contents
        datePicker.date = task.date
        categoryList = Array(task.categoryList)
        
    }
    
    private func modifyUI() {
        // UI更新
        textView.layer.borderColor = UIColor.lightGray.cgColor
        addCategoryButton.layer.borderColor = addCategoryButton.tintColor.cgColor
        addCategoryButton.layer.cornerRadius = addCategoryButton.frame.width / 2
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Taskを書き込む
        try! realm.write {
            task.title = textField.text!
            task.contents = textView.text!
            task.date = datePicker.date
            task.categoryList.removeAll()
            task.categoryList.append(objectsIn: categoryList ?? [])
            
            realm.add(task, update: .modified)
        }
        
        setNotification(task: task)
    }
    
    // 通知の設定
    func setNotification(task: Task) {
        // 通知の中身作成
        let content = UNMutableNotificationContent()
        
        content.title = task.getTitle()
        content.body = task.getContents()
        
        content.sound = UNNotificationSound.default
        
        
        // トリガーの設定
        // 現在日時からタスクの期限までの差を取得しトリガーに設定
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // 通知の作成
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        // 通知の登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録OK")
        }
        
        // 未通知のローカル通知一覧　ログ集力
        center.getPendingNotificationRequests { (requests) in
            requests.forEach{
                print("--------")
                print($0)
                print("--------")
            }
        }
        
    }
    
    // カテゴリ一覧画面に遷移
    @IBAction func tappedAddCategoryButton(_ sender: Any) {
        performSegue(withIdentifier: "categorySegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let categoryVC = segue.destination as! CategoryListViewController
        categoryVC.delegate = self
    }
}
// デリゲート（選択されたカテゴリ一覧を取得）
extension InputViewController: CategoryListViewControllerDelegate {
    func setCategoryList(_ categoryList: [Category]) {
        self.categoryList = categoryList
    }
}
