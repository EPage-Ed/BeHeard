//
//  AuthVM.swift
//  BeHeard
//
//  Created by Edward Arenberg on 11/15/24.
//

import Foundation
import FirebaseAuth

struct BHUser {
  let user: User?
  let age: Int
  let gender: String
  let state: String
}

class AuthViewModel: ObservableObject {
  @Published var user: User?
  @Published var bhUser: BHUser?
  @Published var errorMessage: String?
  
  static let usStates: [String: String] = [
    "AL": "Alabama", "AK": "Alaska", "AZ": "Arizona", "AR": "Arkansas", "CA": "California", "CO": "Colorado", "CT": "Connecticut", "DE": "Delaware", "FL": "Florida",
    "GA": "Georgia", "HI": "Hawaii", "ID": "Idaho", "IL": "Illinois", "IN": "Indiana", "IA": "Iowa", "KS": "Kansas", "KY": "Kentucky", "LA": "Louisiana", "ME": "Maine",
    "MD": "Maryland", "MA": "Massachusetts", "MI": "Michigan", "MN": "Minnesota", "MS": "Mississippi", "MO": "Missouri", "MT": "Montana", "NE": "Nebraska", "NV": "Nevada",
    "NH": "New Hampshire", "NJ": "New Jersey", "NM": "New Mexico", "NY": "New York", "NC": "North Carolina", "ND": "North Dakota", "OH": "Ohio", "OK": "Oklahoma", "OR": "Oregon",
    "PA": "Pennsylvania", "RI": "Rhode Island", "SC": "South Carolina", "SD": "South Dakota", "TN": "Tennessee", "TX": "Texas", "UT": "Utah", "VT": "Vermont", "VA": "Virginia",
    "WA": "Washington", "WV": "West Virginia", "WI": "Wisconsin", "WY": "Wyoming"
  ]
  static let usStates2: [String: String] = [
    "Alabama": "AL", "Alaska": "AK", "Arizona": "AZ", "Arkansas": "AR", "California": "CA", "Colorado": "CO", "Connecticut": "CT", "Delaware": "DE", "Florida": "FL",
    "Georgia": "GA", "Hawaii": "HI", "Idaho": "ID", "Illinois": "IL", "Indiana": "IN", "Iowa": "IA", "Kansas": "KS", "Kentucky": "KY", "Louisiana": "LA", "Maine": "ME",
    "Maryland": "MD", "Massachusetts": "MA", "Michigan": "MI", "Minnesota": "MN", "Mississippi": "MS", "Missouri": "MO", "Montana": "MT", "Nebraska": "NE", "Nevada": "NV",
    "New Hampshire": "NH", "New Jersey": "NJ", "New Mexico": "NM", "New York": "NY", "North Carolina": "NC", "North Dakota": "ND", "Ohio": "OH", "Oklahoma": "OK", "Oregon": "OR",
    "Pennsylvania": "PA", "Rhode Island": "RI", "South Carolina": "SC", "South Dakota": "SD", "Tennessee": "TN", "Texas": "TX", "Utah": "UT", "Vermont": "VT", "Virginia": "VA",
    "Washington": "WA", "West Virginia": "WV", "Wisconsin": "WI", "Wyoming": "WY"
  ]
  
  func signIn(email: String, password: String) async {
    do {
      let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
      print("Login User: \(authResult.user)")
      DispatchQueue.main.async {
        self.user = authResult.user
      }
    } catch {
      do {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        print("New User: \(authResult.user)")
        DispatchQueue.main.async {
          self.user = authResult.user
        }
      } catch {
        print(error.localizedDescription)
        DispatchQueue.main.async {
          self.errorMessage = error.localizedDescription
        }
      }
      /*
      DispatchQueue.main.async {
        self.errorMessage = error.localizedDescription
      }
       */
    }
  }
  
  func signOut() {
    do {
      try Auth.auth().signOut()
      self.user = nil
    } catch {
      self.errorMessage = error.localizedDescription
    }
  }
}
