//
//  TaskDetailViewController.swift
//  TodoList
//
//  Created by KhoaLA8 on 18/6/24.
//

import Foundation
import UIKit
import ProgressHUD

class TaskDetailViewController : UITableViewController, StatusTableDelegate {
    //MARK: - IBOutlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showTaskData()
    }
    
    private func showTaskData() {
        self.title = task?.title
        titleTextField.text = task?.title
        statusLabel.text = task?.status
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            performSegue(withIdentifier: "editTaskStatusSeg", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTaskStatusSeg" {
            if let destinationVC = segue.destination as? StatusTableViewController {
                destinationVC.currentTask = task
                destinationVC.delegate = self
            }
        }
    }
    
    func updateTask(task taskUpdated: Task) {
        task = taskUpdated
        showTaskData()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if titleTextField.text != "" {
            task?.title = titleTextField.text!
            FirebaseTaskListener.shared.saveTask(task!)
            ProgressHUD.success("Edit task successfully")
        }else{
            ProgressHUD.failed("title is required")
        }
    }
}
