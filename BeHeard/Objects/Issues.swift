//
//  Issues.swift
//  BeHeard
//
//  Created by Edward Arenberg on 11/15/24.
//

import Foundation
import FirebaseFirestore

struct Issue : Codable {
  let title: String
  var count: Int
}

struct IssueVote : Codable {
  @DocumentID var id: String?
  let issues: [Issue]
  let age: Int
  let gender: String
  let state: String
  
  static func merge(votes: [IssueVote]) -> [Issue] {
    var issues = IssueList.initial.issues
    votes.forEach { vote in
      vote.issues.forEach { issue in
        if let index = issues.firstIndex(where: { $0.title == issue.title }) {
          issues[index].count += issue.count
        } else {
          issues.append(issue)
        }
      }
    }
    return issues // .sorted { $0.count > $1.count }
  }
  
  static func generateVotes(count: Int = 10) {
    let issues = IssueList.initial.issues
    let states = ["CA","TX","NY","FL","IL","PA","OH","GA","NC","MI"]
    let ages = [18,25,30,35,45,55,65,75]
    let genders = ["Male","Female","Nonbinary"]
    var votes: [IssueVote] = []
    for _ in 0..<count {
      let state = states.randomElement()!
      let age = ages.randomElement()!
      let gender = genders.randomElement()!
      var myIssues = [Issue]()
      var points = 10
      while points > 0 {
        let count = min(points, Int.random(in: 1...5))
        let issue = issues.randomElement()!
        points -= count
        myIssues.append(Issue(title: issue.title, count: count))
      }
      let vote = IssueVote(issues: myIssues, age: age, gender: gender, state: state)
      votes.append(vote)
    }

    let db = Firestore.firestore()
    votes.forEach { vote in
      let ref = db.collection("UserIssues").document()
      try? ref.setData(from: vote)
    }
  }

}

final class IssueList {
  var issues: [Issue] = []
  
  init(issues: [Issue]) {
    self.issues = issues
  }
  
  func addIssue(_ title: String) {
    if let index = issues.firstIndex(where: { $0.title == title }) {
      issues[index].count += 1
    } else {
      issues.append(Issue(title: title, count: 1))
    }
  }
  
  subscript(index: Int) -> Issue {
    get { issues[index] }
    set { issues[index] = newValue }
  }
  
  subscript(title: String) -> Int {
    get {
      if let index = issues.firstIndex(where: { $0.title == title }) {
        return issues[index].count
      } else {
        return 0
      }
    }
    set {
      if let index = issues.firstIndex(where: { $0.title == title }) {
        issues[index].count = newValue
      } else {
        issues.append(Issue(title: title, count: newValue))
      }
    }
  }
  
  func sorted() -> [Issue] {
    issues.sorted { $0.count > $1.count }
  }
  
  func filter(_ isIncluded: (Issue) -> Bool) -> [Issue] {
    issues.filter(isIncluded)
  }
  
  func map<T>(_ transform: (Issue) -> T) -> [T] {
    issues.map(transform)
  }
  
  func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Issue) -> T) -> T {
    issues.reduce(initialResult, nextPartialResult)
  }
  
  func forEach(_ body: (Issue) -> Void) {
    issues.forEach(body)
  }
  
  func contains(where predicate: (Issue) -> Bool) -> Bool {
    issues.contains(where: predicate)
  }
  
  func allSatisfy(_ predicate: (Issue) -> Bool) -> Bool {
    issues.allSatisfy(predicate)
  }
  
  func first(where predicate: (Issue) -> Bool) -> Issue? {
    issues.first(where: predicate)
  }
  
  func last(where predicate: (Issue) -> Bool) -> Issue? {
    issues.last(where: predicate)
  }
  
  func dropFirst(_ k: Int) -> [Issue] {
    Array(issues.dropFirst(k))
  }
  
  func dropLast(_ k: Int) -> [Issue] {
    issues.dropLast(k)
  }
  
  func prefix(_ maxLength: Int) -> [Issue] {
    Array(issues.prefix(maxLength))
  }
  
  static var initial: IssueList {
    IssueList(issues:
    """
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
      .components(separatedBy: .newlines)
      .map {
        Issue(title: $0, count: 0)
      }
    )
  }
}

