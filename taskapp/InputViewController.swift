//
//  InputViewController.swift
//  taskapp
//
//  Created by takatoshi.ichige on 2021/03/16.
//

import UIKit
import RealmSwift

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
    }
}
