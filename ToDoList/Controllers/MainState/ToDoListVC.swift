//
//  ToDoListVC.swift
//  ToDoList
//
//  Created by Ziad on 24/11/2021.
//

import UIKit
import MapKit
import UserNotifications

class ToDoListVC: UIViewController {

    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nothingView: UIView!
    
    // MARK:- Properties
    private var toDos: [ToDo] = []
    
    // MARK:- LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadToDos()
    }
    
    // MARK:- Public Methods
    class func create() -> ToDoListVC {
        let toDoListVC = UIViewController.create(storyboardName: Storyboards.toDoList, identifier: VCs.toDoList) as! ToDoListVC
        return toDoListVC
    }
    
    func startLocationAnimation() {
        guard let tableView = tableView else { return }
        for cell in tableView.visibleCells {
            let cell = cell as! ToDoCell
            cell.startLocationAnimation()
        }
    }
}

// MARK:- Private Methods
extension ToDoListVC {
    private func setupViews() {
        setupNavigationController()
        setupTableView()
    }
    
    @objc private func loadToDos(_ sender: UIRefreshControl? = nil) {
        if sender == nil {
            view.showActivityIndicator()
        }
        FirebaseManager.shared.loadToDos { [weak self] toDos in
            self?.view.hideActivityIndicator()
            sender?.endRefreshing()
            self?.toDos = toDos
            self?.toDos.sort(by: {$0.date < $1.date})
            self?.handleAvailability()
            self?.tableView.reloadData()
        }
    }
    
    private func setupNavigationController() {
        navigationItem.prompt = "\(FirebaseManager.shared.getUsername()), Welcome Back!"
        title = "To Do"
        let plusItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(newToDoTapped))
        navigationItem.rightBarButtonItem = plusItem
        let logoutItem = UIBarButtonItem(image: UIImage(systemName: "power"), style: .done, target: self, action: #selector(displayLogoutAlert))
        logoutItem.tintColor = .systemRed
        navigationItem.leftBarButtonItem = logoutItem
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 116
        tableView.register(UINib(nibName: Cells.toDoCell, bundle: nil), forCellReuseIdentifier: Cells.toDoCell)
        tableView.delegate = self
        tableView.dataSource = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadToDos(_:)), for: .valueChanged)
        tableView.backgroundView = refreshControl
    }
    
    @objc private func newToDoTapped() {
        let newToDoVC = NewToDoVC.create(delegate: self)
        let newToDoNav = UINavigationController(rootViewController: newToDoVC)
        present(newToDoNav, animated: true, completion: nil)
    }
    
    @objc private func displayLogoutAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { [weak self] _ in
            self?.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func logout() {
        FirebaseManager.shared.logout { [weak self] loggedOut, error in
            if let error = error {
                self?.showAlert(title: "Sorry", message: error)
            } else if loggedOut {
                self?.switchToAuthState()
            }
        }
    }
    
    private func handleAvailability() {
        if toDos.count == 0 {
            setNothingView(alpha: 1)
        } else {
            setNothingView(alpha: 0)
        }
    }
    
    private func setNothingView(alpha: CGFloat) {
        UIView.animate(withDuration: 0.7) { [weak self] in
            self?.nothingView.alpha = alpha
        }
    }
    
    private func removeNotificationIfActive(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}

// MARK:- TableView Delegate
extension ToDoListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        toDos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.toDoCell, for: indexPath) as! ToDoCell
        cell.configure(with: toDos[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        FirebaseManager.shared.deleteToDo(id: toDos[indexPath.row].id)
        removeNotificationIfActive(id: toDos[indexPath.row].id)
        toDos.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        handleAvailability()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK:- ToDoCell Delegate
extension ToDoListVC: ToDoCellProtocol {
    func locationTapped(cell: ToDoCell) {
        guard let indexPath = tableView.indexPath(for: cell), let location = toDos[indexPath.row].location else { return }
        let coordinates = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = toDos[indexPath.row].title
        mapItem.openInMaps(launchOptions: options)
    }
}

// MARK:- NewToDoVC Delegate
extension ToDoListVC: NewToDoVCProtocol {
    func toDoAdded(toDo: ToDo) {
        toDos.append(toDo)
        toDos.sort(by: {$0.date < $1.date})
        guard let index = toDos.firstIndex(where: {$0.id == toDo.id}) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        handleAvailability()
    }
}
