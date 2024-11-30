//
//  BeHeardApp.swift
//  BeHeard
//
//  Created by Edward Arenberg on 11/15/24.
//

import SwiftUI
import Firebase

@main
struct BeHeardApp: App {
  
  init() {
    FirebaseApp.configure()
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
