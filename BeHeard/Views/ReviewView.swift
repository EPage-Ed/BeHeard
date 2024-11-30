//
//  ReviewView.swift
//  BeHeard
//
//  Created by Edward Arenberg on 11/21/24.
//

import SwiftUI
import Charts
import FirebaseFirestore

/*
  id: age, gender, state, [issue]
 
 */

struct ReviewView: View {
  let usStates = [
    "All States", "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia",
    "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
    "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey",
    "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
    "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
  ]
  let ageGroups = ["All Ages", "18-29", "30-44", "45-64", "65+"]
  let genders = ["All Genders", "Male", "Female", "Nonbinary"]
  
  @State private var state = "All States"
//  @State private var ageGroup = "All Ages"
//  @State private var gender = "All Genders"
  @State private var allIssueVotes: [IssueVote] = []
  @State private var issues: [Issue] = []
  @State private var ageIssues: [String:[Issue]] = [:]
  @State private var genderIssues: [String:[Issue]] = [:]
  @State private var issueAges: [String:[Int]] = [:]
  @State private var issueGenders: [String:[Int]] = [:]

  enum Grouping : String {
    case none
    case age
    case gender
  }
  @State private var grouping: Grouping = .none
  
  func genGraphs(state: String = "All States") {
    ageGroups.forEach { ag in
      ageIssues[ag] = IssueVote.merge(votes: allIssueVotes.filter {
        ($0.state == state || state == "All States") && (
          ag == "All Ages" ||
          ag == "65+" && $0.age >= 65 ||
          ag.components(separatedBy: "-").count == 2 && $0.age >= Int(ag.components(separatedBy: "-")[0])! && $0.age <= Int(ag.components(separatedBy: "-")[1])!
        )
      })
    }
    genders.forEach { g in
      genderIssues[g] = IssueVote.merge(votes: allIssueVotes.filter {
        ($0.state == state || state == "All States") && (
          g == "All Genders" ||
          g == $0.gender
        )
      })
    }
    self.issues.forEach { issue in
      issueAges[issue.title] = Array(repeating: 0, count: ageGroups.count)
      ageGroups.enumerated().forEach { i,ag in
        if let index = ageIssues[ag]?.firstIndex(where: { $0.title == issue.title }) {
          issueAges[issue.title, default: []][i] += ageIssues[ag]![index].count
        }
      }
      issueGenders[issue.title] = Array(repeating: 0, count: genders.count)
      genders.enumerated().forEach { i,g in
        if let index = genderIssues[g]?.firstIndex(where: { $0.title == issue.title }) {
          issueGenders[issue.title, default: []][i] += genderIssues[g]![index].count
        }
      }
    }
    print(issueAges)
    print(issueGenders)

  }

  var body: some View {
    VStack {
      Text("Review")
        .font(.title)

      HStack(spacing: 10) {
        Text("Filter:")
        Spacer()
        Menu(state) {
          ForEach(usStates, id: \.self) { state in
            Button(state) {
              //              print("Selected: \(state)")
              self.state = state
            }
            .padding(.horizontal)
          }
        }
        .padding(4)
        .fixedSize()
        .background {
          Color.white
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
      }
      .font(.title2)
      .padding(8)
      .background(.thinMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .padding(.horizontal)
      
      HStack {
        Text("Group By:")
        Spacer()
        Picker("Age", selection: $grouping) {
          Text("None").tag(Grouping.none)
          Text("Age").tag(Grouping.age)
          Text("Gender").tag(Grouping.gender)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        
        /*
        Menu(ageGroup) {
          ForEach(ageGroups, id: \.self) { ag in
            Button(ag) {
              //              print("Selected: \(state)")
              self.ageGroup = ag
            }
          }
        }
        .padding(4)
        .fixedSize()
        .background {
          Color.white
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        
        Menu(gender) {
          ForEach(genders, id: \.self) { g in
            Button(g) {
              //              print("Selected: \(state)")
              self.gender = g
            }
          }
        }
        .padding(4)
        .fixedSize()
        .background {
          Color.white
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        
        Spacer()
         */
      }
      .font(.title2)
//      .minimumScaleFactor(0.5)
      .padding(8)
      .background(.thinMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .padding(.horizontal)
      
      Spacer()

      switch grouping {
      case .none:
        ScrollView {
          ForEach(issues.sorted(by: { $0.count > $1.count }), id:\.self.title) { issue in
            HStack {
              Text("\(issue.title):")
              Spacer()
              Text("\(issue.count)")
            }
            .padding(.vertical, 4)
          }
        }
        .font(.title3)
        .padding()
      case .age:
        ScrollView {
          ForEach(issues.sorted(by: { $0.count > $1.count }), id:\.self.title) { issue in
            VStack {
              Text("\(issue.title)")
              if let ia = issueAges[issue.title] {
                let d = Array(zip(ia.indices, ia))
                //            ForEach(d, id:\.0) { i,c in
                //              Text("\(ageGroups[i]): \(c)")
                //            }
                Chart(d, id: \.0) { i,c in
                  BarMark(
                    x: .value("Age Range", ageGroups[i]),
                    y: .value("Count", c)
                  )
                  .foregroundStyle(by: .value("Age Range", ageGroups[i]))
                }
                .padding()
                /*
                 Chart(d) { i,c in
                 BarMark(
                 x: .value("Age Range", ageGroups[i]),
                 y: .value("Count", c)
                 )
                 }
                 */
                /*
                 Chart(Array(zip(ia.indices, ia), id:\.1)) { agi, cnt in
                 BarMark(
                 x: .value("Age Range", ageGroups[agi]),
                 y: .value("Count", cnt)
                 )
                 //            .foregroundStyle(by: .value("Age Range", ageGroup.ageRange))
                 }
                 */
              }
              //          .chartXAxisLabel("Age Range")
              //          .chartYAxisLabel("Count")
              //          .padding()
            }
          }
        }
      case .gender:
        ScrollView {
          ForEach(issues.sorted(by: { $0.count > $1.count }), id:\.self.title) { issue in
            VStack {
              Text("\(issue.title)")
              if let ia = issueGenders[issue.title] {
                let d = Array(zip(ia.indices, ia))
                //            ForEach(d, id:\.0) { i,c in
                //              Text("\(ageGroups[i]): \(c)")
                //            }
                Chart(d, id: \.0) { i,c in
                  BarMark(
                    x: .value("Gender", genders[i]),
                    y: .value("Count", c)
                  )
                  .foregroundStyle(by: .value("Gender", genders[i]))
                }
                .padding()
              }
            }
          }
        }
      }

    }
    .task {
      let db = Firestore.firestore()
//      let issuesRef = db.collection("issues")
      /*
      let query = issuesRef.whereField("state", isEqualTo: state)
        .whereField("age", isEqualTo: ageGroup)
        .whereField("gender", isEqualTo: gender)
       */
      if let issues = try? await db.collection("UserIssues").getDocuments() {
        allIssueVotes = issues.documents.compactMap { doc -> IssueVote? in
          try? doc.data(as: IssueVote.self)
        }
        self.issues = IssueVote.merge(votes: allIssueVotes)
        
        genGraphs()
      }

    }
    .onChange(of: state) { _,val in
      withAnimation {
        let state = AuthViewModel.usStates2[val] ?? "All States"
        let stateVotes = val == "All States" ? allIssueVotes : allIssueVotes.filter { $0.state == state }
        self.issues = IssueVote.merge(votes: stateVotes)
        genGraphs(state: state)
      }
    }
    /*
    .onChange(of: ageGroup) { _,val in
      self.issues = ageIssues[val] ?? []
      /*
      self.issues = IssueVote.merge(votes: allIssueVotes.filter {
        ageGroup == "All Ages" ||
        ageGroup == "65+" && $0.age >= 65 ||
        ageGroup.components(separatedBy: "-").count == 2 && $0.age >= Int(ageGroup.components(separatedBy: "-")[0])! && $0.age <= Int(ageGroup.components(separatedBy: "-")[1])!
      })
       */
    }
     */
  }
}

#Preview {
  ReviewView()
}
