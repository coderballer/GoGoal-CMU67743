//
//  AuthSession.swift
//  GoGoal
//
//  Created by Sihan Chen on 11/14/21.
//

import Foundation
import FirebaseAuth

class AuthSession: ObservableObject {
  
  @Published var isLoggedin: Bool = false
  @Published var userViewModel = UserViewModel()
  
  func login(userEmail: String, _ completion: @escaping () -> Void = {}) {
    self.userViewModel.userService.getByEmail(email: userEmail) {
      if let user = $0 {
        self.userViewModel.user = user
        self.userViewModel.fetchAllUserGoals() {
          self.isLoggedin = true
          completion()
        }
      } else {
        do {
          try Auth.auth().signOut()
        } catch let err {
          print("Error sign out: \(err)")
        }
        
        print("""
        =================================================
        
        Warning: user auth valid but user not exist!
        
        Account email: \(userEmail)
        Current env: \(EnvironmentConfig.getEnv())
        
        Possible reasons:
          (1) user was deleted in current env firestore
          (2) user has valid local session in another env
              but app now switched to current env
        
        =================================================
        """)
        
        completion()
      }
    }
  }
  
  func logout() {
    self.userViewModel = UserViewModel()
    self.isLoggedin = false
  }
  
}
