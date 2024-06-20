//
//  StatusTableViewController.swift
//  TodoList
//
//  Created by KhoaLA8 on 19/6/24.
//

import Foundation
import UIKit

protocol StatusTableDelegate: AnyObject {
    func updateTask(task: Task)
}

class StatusTableViewController: UITableViewController {
    
    var allStatus: [String] = []
    var currentTask: Task?
    
    weak var delegate: StatusTableDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        loadTaskStatus()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allStatus.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let status = allStatus[indexPath.row]
        cell.textLabel?.text = status
        
        cell.accessoryType = currentTask?.status == status ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        updateCellCheck(indexPath)
        tableView.reloadData()
    }
    
    private func loadTaskStatus() {
        
        allStatus = userDefaults.object(forKey: kSTATUS) as! [String]
        tableView.reloadData()
    }
    
    private func updateCellCheck(_ indexPath: IndexPath) {
        currentTask?.status = allStatus[indexPath.row]
        FirebaseTaskListener.shared.saveTask(currentTask!)
        delegate?.updateTask(task: currentTask!)
    }
    
}
