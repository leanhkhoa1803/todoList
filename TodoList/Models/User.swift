//
//  User.swift
//  TodoList
//
//  Created by KhoaLA8 on 17/6/24.
//

import Foundation

import Firebase


struct User: Codable, Equatable {
    
    var id = ""
    var username: String
    var email: String
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                
                let decoder = JSONDecoder()
                
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch {
                    print("Error decoding user", error.localizedDescription)
                }
            }
        }
        
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}



func saveUserLocally(_ user: User) {
    
    let encoder = JSONEncoder()
    
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    } catch {
        print("error saving user locally ", error.localizedDescription)
    }
}

