//
//  NewToDoVC.swift
//  ToDoList
//
//  Created by Ziad on 24/11/2021.
//

import UIKit
import TextFieldEffects
import MapKit
import UserNotifications

protocol NewToDoVCProtocol: AnyObject {
    func toDoAdded(toDo: ToDo)
}

class NewToDoVC: UIViewController {

    // MARK:- Outlets
    @IBOutlet weak var titleTextField: HoshiTextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinImageView: UIImageView!
    
    // MARK:- Properties
    private weak var delegate: NewToDoVCProtocol?
    
    // MARK:- LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK:- Public Methods
    class func create(delegate: NewToDoVCProtocol) -> NewToDoVC {
        let newToDoVC = UIViewController.create(storyboardName: Storyboards.newToDo, identifier: VCs.newToDo) as! NewToDoVC
        newToDoVC.delegate = delegate
        return newToDoVC
    }
    
    @IBAction func reminderSwitchTriggered(_ sender: UISwitch) {
        if sender.isOn {
            checkNotificationsPermission()
        }
    }
    
    @IBAction func locationSwitchTriggered(_ sender: UISwitch) {
        view.endEditing(true)
        if sender.isOn {
            setMapView(alpha: 1)
        } else {
            setMapView(alpha: 0)
        }
    }
}

// MARK:- Private Methods
extension NewToDoVC {
    private func setupViews() {
        setupNavigationController()
        setupDatePicker()
        setupMapView()
    }
    
    private func setupNavigationController() {
        title = "Add New To Do"
        let cancelItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancelItem
        let addItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = addItem
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func addTapped() {
        view.endEditing(true)
        if let titleError = ValidationManager.shared().isValid(.title(titleTextField.text)) {
            showAlert(title: "Sorry", message: titleError)
            return
        }
        guard let id = FirebaseManager.shared.generateAutoId() else {
            showAlert(title: "Sorry", message: "Connection issue, please try again later")
            return
        }
        let toDo = ToDo(id: id, title: titleTextField.text!.trimmed, date: datePicker.date, location: getLocation(), activeReminder: reminderSwitch.isOn)
        uploadToDo(toDo: toDo)
    }
    
    private func setupDatePicker() {
        datePicker.minimumDate = Date()
    }
    
    private func setupMapView() {
        mapView.layer.cornerRadius = 20
    }
    
    private func setMapView(alpha: CGFloat) {
        UIView.animate(withDuration: 0.7) { [weak self] in
            self?.mapView.alpha = alpha
            self?.pinImageView.alpha = alpha
        }
    }
    
    private func getLocation() -> Location? {
        guard locationSwitch.isOn else { return nil }
        return Location(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
    }
    
    private func uploadToDo(toDo: ToDo) {
        view.showActivityIndicator()
        FirebaseManager.shared.addToDo(toDo: toDo) { [weak self] added, error in
            self?.view.hideActivityIndicator()
            if let error = error {
                self?.showAlert(title: "Sorry", message: error)
            } else if added {
                self?.scheduleNotificationIfReminderActivated(toDoId: toDo.id)
                self?.dismiss(animated: true, completion: {
                    self?.delegate?.toDoAdded(toDo: toDo)
                })
            }
        }
    }
    
    private func checkNotificationsPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            if !granted {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Sorry!", message: "Please accept notifications permission from your privacy settings")
                    self?.reminderSwitch.isOn = false
                }
            }
        }
    }
    
    private func scheduleNotificationIfReminderActivated(toDoId: String) {
        guard reminderSwitch.isOn else { return }
        let dateComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: datePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "It's time for \(titleTextField.text!.trimmed)"
        content.body = "Dont miss it!"
        //content.categoryIdentifier = "customIdentifier"
        //content.userInfo = ["customData": "fizzbuzz"]
        content.sound = .default
        let request = UNNotificationRequest(identifier: toDoId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
