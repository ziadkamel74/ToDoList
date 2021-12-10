//
//  FirebaseManager.swift
//  ToDoList
//
//  Created by Ziad on 20/11/2021.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

struct FirebaseManager {
    
    // MARK:- Singleton
    static let shared = FirebaseManager()
    private init() {}
    
    // MARK:- Properties
    private let ref = Database.database().reference()
    
    // MARK:- Public Methods
    func login(email: String, password: String, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { auth, error in
            guard error == nil, let auth = auth else {
                completion(false, error?.localizedDescription)
                return
            }
            UserDefaultsManager.shared.token = auth.user.uid
            completion(true, nil)
        }
    }
    
    func register(email: String, name: String, password: String, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { auth, error in
            guard error == nil, let auth = auth else {
                completion(false, error?.localizedDescription)
                return
            }
            let nameRequest = auth.user.createProfileChangeRequest()
            nameRequest.displayName = name
            nameRequest.commitChanges { error in
                guard error == nil else {
                    completion(false, error?.localizedDescription)
                    return
                }
                UserDefaultsManager.shared.token = auth.user.uid
                completion(true, nil)
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            guard error == nil else {
                completion(false, error?.localizedDescription)
                return
            }
            completion(true, nil)
        }
    }
    
    func logout(completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        do {
            try Auth.auth().signOut()
            UserDefaultsManager.shared.token = nil
            completion(true, nil)
        } catch {
            completion(false, error.localizedDescription)
            print(error)
        }
    }
    
    func getUsername() -> String {
        return Auth.auth().currentUser?.displayName ?? ""
    }
    
    func loadToDos(completion: @escaping (_ toDos: [ToDo]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref.child("ToDos").child(uid).observeSingleEvent(of: .value) { snapshot, error in
            guard error == nil else { return }
            var toDos: [ToDo] = []
            for child in snapshot.children {
                if let child = child as? DataSnapshot, let dict = child.value as? [String: Any], let id = dict["id"] as? String, let title = dict["title"] as? String, let date = dict["date"] as? String, let activeReminder = dict["activeReminder"] as? Bool {
                    var location: Location?
                    if let latitude = dict["latitude"] as? Double, let longitude = dict["longitude"] as? Double {
                        location = Location(latitude: latitude, longitude: longitude)
                    }
                    let toDo = ToDo(id: id, title: title, date: String.getDate(from: date), location: location, activeReminder: activeReminder)
                    toDos.append(toDo)
                }
            }
            completion(toDos)
        }
    }
    
    func deleteToDo(id: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref.child("ToDos").child(uid).child(id).removeValue()
    }
    
    func addToDo(toDo: ToDo, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref.child("ToDos").child(uid).child(toDo.id).setValue(toDo.asDict()) { error, _ in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func generateAutoId() -> String? {
        return ref.childByAutoId().key
    }
}
