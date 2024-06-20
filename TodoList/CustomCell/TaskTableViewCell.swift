//
//  TaskTableViewCell.swift
//  TodoList
//
//  Created by KhoaLA8 on 18/6/24.
//

import Foundation
import UIKit

class TaskTableViewCell : UITableViewCell{
    //MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeCreateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusLabel.layer.cornerRadius = 20
        statusLabel.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func configure(task: Task) {
        titleLabel.text = task.title
        statusLabel.text = task.status
        timeCreateLabel.text = task.createdDate?.stringDate()
        
        switch task.status {
        case Status.NotStarted.rawValue:
            statusLabel.backgroundColor = .darkGray
        case Status.InProgress.rawValue:
            statusLabel.backgroundColor = .green
        case Status.OnHold.rawValue:
            statusLabel.backgroundColor = .red
        default:
            statusLabel.backgroundColor = .blue
        }
    }
    
}
