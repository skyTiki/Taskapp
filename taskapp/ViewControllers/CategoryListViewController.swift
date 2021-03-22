//
//  CategoryListViewController.swift
//  taskapp
//
//  Created by takatoshi.ichige on 2021/03/22.
//

import UIKit

class CategoryListViewController: UIViewController {

    @IBOutlet weak var categoryTableView: UITableView!
    
    var categoryList = ["家事", "勉強"]
    var selectedCategoryList: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        cell.textLabel?.text = categoryList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let selectedCategoryTitle = cell.textLabel!.text else { return }
        
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
            selectedCategoryList.append(selectedCategoryTitle)
        } else if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            selectedCategoryList.removeAll(where: { $0 == selectedCategoryTitle })
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        print(selectedCategoryList)
    }
    
}
