//
//  CustomCell.swift
//  CoreDataDemo
//
//  Created by Василий Полторак on 24.05.2022.
//

import UIKit

class CustomCell: UITableViewCell {
    
    var taskLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(taskLabel)
        setConstraintsForTaskLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setConstraintsForTaskLabel() {
        taskLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            taskLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            taskLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            taskLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
            taskLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8),
            taskLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
    }


}
