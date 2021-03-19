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
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var task: Task!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture: UITapGestureRecognizer = .init(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        textField.text = task.title
        textView.text = task.contents
        datePicker.date = task.date
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        try! realm.write {
            task.title = textField.text!
            task.contents = textView.text!
            task.date = datePicker.date
            
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
}
