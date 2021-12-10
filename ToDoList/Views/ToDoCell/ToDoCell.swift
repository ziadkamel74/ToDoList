//
//  ToDoCell.swift
//  ToDoList
//
//  Created by Ziad on 25/11/2021.
//

import UIKit

protocol ToDoCellProtocol: AnyObject {
    func locationTapped(cell: ToDoCell)
}

class ToDoCell: UITableViewCell {
    
    // MARK:- Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    
    // MARK:- Properties
    weak var delegate: ToDoCellProtocol?

    // MARK:- LifeCycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        startLocationAnimation()
    }
    
    // MARK:- Actions
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        delegate?.locationTapped(cell: self)
    }
    
    // MARK:- Public Methods
    func configure(with toDo: ToDo) {
        titleLabel.text = toDo.title
        dateLabel.text = String.getString(from: toDo.date)
        locationButton.isHidden = toDo.location == nil
    }
    
    func startLocationAnimation() {
        locationButton.layer.removeAllAnimations()
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0.1
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        locationButton.layer.add(pulseAnimation, forKey: "animateOpacity")
    }
}
