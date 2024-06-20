//
//  AddTaskViewController.swift
//  TodoList
//
//  Created by KhoaLA8 on 18/6/24.
//

import Foundation
import UIKit
import ProgressHUD

class AddTaskViewController : UITableViewController{
    //MARK: - IBOutlet
    @IBOutlet weak var titleTextView: UITextView!
    
    var taskId = UUID().uuidString
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if titleTextView.text != "" {
            saveTask()
        } else {
            ProgressHUD.error("title is empty!")
        }
    }
    
    private func saveTask() {
        
        let task = Task(id: taskId, title: titleTextView.text!, userId: User.currentId)
        
        FirebaseTaskListener.shared.saveTask(task)
        
        self.navigationController?.popViewController(animated: true)
    }
}
