//
//  MainView.swift
//  GoGoal
//
//  Created by Sihan Chen on 10/17/21.
//

import SwiftUI

struct MainView: View {
  
  @ObservedObject var userViewModel: UserViewModel
  
  var body: some View {
    TabView {
      UserGoalView(userViewModel: self.userViewModel)
        .tabItem {
          Image(systemName: "bolt.horizontal.circle")
        }
      
      CommunityView(userViewModel: self.userViewModel)
        .tabItem {
          Image(systemName: "network")
        }
      
      AchievementView(userViewModel: self.userViewModel)
        .tabItem {
          Image(systemName: "folder.circle")
        }
      
      ProfileView(userViewModel: self.userViewModel)
        .tabItem {
          Image(systemName: "person")
        }
    }
    .onAppear(perform: {
      NotificationManager.shared.requestAuthorization() { granted in
        if granted {
          NotificationManager.shared.scheduleNotification()
        } else {
          NotificationManager.shared.clearNotification()
        }
      }
    })
  }
  
}
