//
//  Concerns.swift
//  BeHeard
//
//  Created by Edward Arenberg on 11/17/24.
//

import Foundation
import FirebaseFirestore
// import FirebaseFirestoreSwift

let c2 = """
The economy
Democracy in the U.S.
Terrorism and national security
Types of Supreme Court justices candidates would pick
Immigration
Education
Healthcare
Gun policy
Abortion
Taxes
Crime
Distribution of income and wealth in the U.S.
The federal budget deficit
Foreign affairs
Situation in Middle East between Israelis and Palestinians
Energy policy
Relations with Russia
Race relations
Relations with China
Trade with other nations
Climate change
Transgender rights
"""

let c1 = """
Inflation/prices
Immigration
Jobs & the economy
Abortion
Healthcare
Climate & the environment
National security
Taxes & government spending
Civil rights
Education
Civil liberties
Guns
Crime
Foreign policy
Criminal justice reform
"""

let c3 = """
Inflation
Affordable Health Care
Drug Addiction
Gun Violence
Illegal Immigration
Federal Budget Deficit
Unemployment
Violent Crime
State of Moral Values
Quality of Public K-12 Schools
Climate Change
International Terrorism
Government/Poor Leadership
High Cost of Living
Economy in General
Unifying the Country
Ethics/Moral/Religious/Family Decline
Race Relations/Racism
Poverty/Hunger/Homelessness
Abortion
"""

let cc = """
Abortion
Affordable Health Care
Civil Rights
Climate change / Environment
Crime
Criminal Justice Reform
Cyber Crime
Democracy in the U.S.
Distribution of Income and Wealth
Drug Addiction
Economy in General
Education
Energy Policy
Ethics/Moral/Religious/Family Decline
Federal Budget Deficit
Foreign Policy
Government/Poor Leadership
Gun Policy
Gun Violence
Healthcare
High Cost of Living
Illegal Immigration
Immigration
Inflation / Prices
Jobs
LGBTQ Rights
Middle East Situation
Poverty / Hunger / Homelessness
Quality of Public K-12 Schools
Race Relations / Racism
Relations with China
Relations with Russia
Supreme Court
Taxes & Government Spending
Terrorism and National Security
Trade with Other Nations
Unemployment
Unifying the Country
"""

struct ConcernItem: Codable, Identifiable {
  @DocumentID var id: String? // Firestore document ID
  var title: String
  
  static func buildInitial() {
    let db = Firestore.firestore()
    let concernsString = """
Abortion
Affordable Health Care
Civil Rights
Climate change / Environment
Crime
Criminal Justice Reform
Cyber Crime
Democracy in the U.S.
Distribution of Income and Wealth
Drug Addiction
Economy in General
Education
Energy Policy
Ethics/Moral/Religious/Family Decline
Federal Budget Deficit
Foreign Policy
Government/Poor Leadership
Gun Policy
Gun Violence
Healthcare
High Cost of Living
Illegal Immigration
Immigration
Inflation / Prices
Jobs
LGBTQ Rights
Middle East Situation
Poverty / Hunger / Homelessness
Quality of Public K-12 Schools
Race Relations / Racism
Relations with China
Relations with Russia
Supreme Court
Taxes & Government Spending
Terrorism and National Security
Trade with Other Nations
Unemployment
Unifying the Country
"""
    /*
    let concerns = [
      "Housing",
      "Healthcare",
      "Education",
      "Employment",
      "Safety",
      "Transportation",
      "Environment",
      "Other"
    ]
     */
    let concerns = concernsString.components(separatedBy: .newlines)
    for concern in concerns {
      do {
        let _ = try db.collection("ConcernItems").addDocument(from: ConcernItem(title: concern))
      } catch {
        print("Error writing concern item to Firestore: \(error)")
      }
    }
  }
}

struct Concern: Codable, Identifiable {
  @DocumentID var id: String? // Firestore document ID
  var itemID: String
  var title: String
  var timestamp: Timestamp
  var count: Int
  var age: Int
  var gender: String
  var zipcode: String

  /*
  enum CodingKeys: String, CodingKey {
    case id
    case title
    case timestamp
    case count
    case age
    case gender
    case zipcode
  }
   */
}
