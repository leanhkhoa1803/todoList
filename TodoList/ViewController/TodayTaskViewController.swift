//
//  TodayTaskViewController.swift
//  TodoList
//
//  Created by KhoaLA8 on 18/6/24.
//

import Foundation
import UIKit
import ProgressHUD
import FirebaseAuth

class TodayTaskViewController : UITableViewController {
    //MARK: - Vars
    var allTask: [Task] = []
    var filteredTask: [Task] = []
    var taskSelected: Task?
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        
        tableView.tableFooterView = UIView()
        setupSpinner()
        setupSearchController()
        downloadTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func downloadTasks() {
        showActivityIndicator()
        FirebaseTaskListener.shared.downloadTasksCurrentDayFromFirebase { (error,allFirebaseTasks) in
            self.hideActivityIndicator()
            if let error = error as? NSError, let code = AuthErrorCode.Code(rawValue: error.code){
                if code == AuthErrorCode.networkError {
                    // Handle the case where the device is offline
                    DispatchQueue.main.async {
                        ProgressHUD.failed("The Internet connection is offline, please try again later.")
                    }
                    return
                }
            }
            if allFirebaseTasks == nil {
                self.allTask = []
                let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                emptyLabel.text = "No Task For Today"
                emptyLabel.textAlignment = NSTextAlignment.center
                self.tableView.backgroundView = emptyLabel
                self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
                self.tableView.reloadData()
                return
            }
            self.allTask = allFirebaseTasks!
            self.tableView.backgroundView = nil
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredTask.count : allTask.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskTableViewCell
        
        let task = searchController.isActive ? filteredTask[indexPath.row] : allTask[indexPath.row]
        cell.configure(task: task)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let task = searchController.isActive ? filteredTask[indexPath.row] : allTask[indexPath.row]
            
            FirebaseTaskListener.shared.deleteTask(task)

            searchController.isActive ? self.filteredTask.remove(at: indexPath.row) : allTask.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = searchController.isActive ? filteredTask[indexPath.row] : allTask[indexPath.row]
        
        showTaskDetail(task)
    }
    
    @IBAction func addBarButtonPressed(_ sender: Any) {
        self.hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true
        performSegue(withIdentifier: "addTaskFromTodayTaskSeg", sender: self)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        FirebaseUserListener.shared.logOutCurrentUser { (error) in
            if let error = error as? NSError, let code = AuthErrorCode.Code(rawValue: error.code){
                if code == AuthErrorCode.networkError {
                    // Handle the case where the device is offline
                    DispatchQueue.main.async {
                        ProgressHUD.failed("The Internet connection is offline, please try again later.")
                    }
                    return
                }
            }
            
            if error == nil {
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
                }
            }
        }
    }
    
    func setupSpinner(){
        self.activityIndicator.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:UIScreen.main.bounds.size.height / 4)
        self.view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
    }

    private func setupSearchController() {
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search task"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    private func filteredContentForSearchText(searchText: String) {
        
        filteredTask = allTask.filter({ (task) -> Bool in
            return task.title.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    private func showTaskDetail(_ task: Task) {
        taskSelected = task
        self.hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true
        performSegue(withIdentifier: "detailTaskFromTodayTaskSeg", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailTaskFromTodayTaskSeg" {
            if let destinationVC = segue.destination as? TaskDetailViewController {
                destinationVC.task = taskSelected
            }
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if self.refreshControl!.isRefreshing {
            self.downloadTasks()
            self.refreshControl!.endRefreshing()
        }
    }
    
    func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}

extension TodayTaskViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
