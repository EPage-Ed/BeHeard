//
//  MyIssuesView.swift
//  BeHeard
//
//  Created by Edward Arenberg on 11/16/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CounterView: View {
  @ObservedObject var vm: IssueVM
  @State var selectedIssue: Int = -1
//  @State private var count: Int = 0
//  var canCount = true
//  private var count : Int {
//    get { issue?.count ?? 0 }
//    set { issue?.count = newValue }
//  }
  
  var body: some View {
    VStack(spacing: 0) {
      if let i = vm.selectedIssue {
        Text(vm.issueList[i].title)
          .font(.title)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
      } else {
        Text("Select an issue")
          .font(.title)
          .padding(.horizontal)
      }
      HStack(alignment: .center, spacing: 20) {
        if let i = vm.selectedIssue {
          Text("\(vm.issueList[i].count)")
            .font(.largeTitle)
//            .padding(.bottom, 10)
          
          Stepper("",
                  value: $vm.issueList[i].count,
//                  value: .init(get: { issue?.count ?? 0 },
//                               set: { issue?.count = $0 }),
                  in: 0...(vm.points + vm.issueList[i].count))
          .labelsHidden()
//          .disabled(vm.points == 0)
        }
      }
      .padding(8)
      
//      Spacer()

    }
    .padding()
  }
}

struct HelpView: View {
  @Binding var showHelp: Bool

  var body: some View {
    VStack {
      VStack(spacing: 16) {
        Spacer()
        Text("You have 10 points to distribute")
        Text("Select issues most important to you")
        Text("Allocate points as you see fit")
        Spacer()
      }
      .padding(.horizontal)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
      .font(.title)
      /*
      Button("", systemImage: "xmark.circle") {
        withAnimation {
          showHelp.toggle()
        }
      }
      .font(.title)
      .tint(.red)
      .offset(y: -10)
      .padding(.vertical)
       */
    }
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 25.0))
    .overlay(alignment: .topTrailing) {
      Button("", systemImage: "xmark.circle") {
        withAnimation {
          showHelp.toggle()
        }
      }
      .font(.title)
      .tint(.red)
      .offset(x: 8, y: -8)
    }
  }
}

final class IssueVM : ObservableObject {
  @Published var issueList = IssueList.initial
  @Published var selectedIssue: Int?
  @Published var changed = false
  @Published var saving = false
  var points : Int {
    max(0, min(10, 10 - issueList.reduce(0) { $0 + $1.count }))
  }
  subscript(index: Int) -> Issue {
    get { issueList[index] }
    set { issueList[index] = newValue }
  }
  @MainActor
  func save(user: BHUser) async {
    saving = true
    Task {
      let db = Firestore.firestore()
      let docRef = db.collection("UserIssues").document(user.user!.uid)
      do {
        let iv = IssueVote(issues: issueList.issues, age: user.age, gender: user.gender, state: user.state)
//        let obj = ["issues": issueList.issues]
        try docRef.setData(from: iv)
      } catch let err {
        print(err)
      }
      DispatchQueue.main.async {
        self.saving = false
      }
    }
    
    /*
    docRef.setData(["issues": issueList.map { $0.title },
                    "counts": issueList.map { $0.count }
    ]) { err in
      if let err = err {
        print("Error writing document: \(err)")
      } else {
        print("Document successfully written!")
      }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.saving = false
    }
     */
  }
  @MainActor
  func load(user: BHUser) async throws {
//    if user == "unknown" { return }
    saving = true
    Task {
      let db = Firestore.firestore()
      let docRef = db.collection("UserIssues").document(user.user!.uid)
      let doc = try await docRef.getDocument()
      if doc.exists {
        let iv = try doc.data(as: IssueVote.self)
//        guard let issues = obj["issues"] else { return }
        issueList = IssueList(issues: iv.issues)
      }
      DispatchQueue.main.async {
        self.saving = false
        self.changed = false
      }
    }
  }
}

struct MyIssuesView: View {
  @StateObject private var vm = IssueVM()
  @State private var showHelp = false
  var user : BHUser
//  @State private var selectedIssue: Int = -1
  
  var body: some View {
    let _ = Self._printChanges()
    VStack {
      CounterView(vm: vm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
        .overlay(alignment: .topTrailing) {
          Button("", systemImage: "info.circle") {
            withAnimation {
              showHelp.toggle()
//              vm.selectedIssue = nil
            }
          }
          .font(.title)
          .offset(x: 8, y: -8)
        }
        .padding(.top)

      
      Text("Remaining points: **\(vm.points)**")
        .font(.title)
        .padding(.horizontal)
      
      List(Array(vm.issueList.issues.enumerated()), id: \.offset) { i, issue in
        HStack {
          Text(issue.title)
          Spacer()
          Text("\(issue.count)")
            .font(.title2)
        }
        .contentShape(Rectangle())
        .background(
          RoundedRectangle(cornerRadius: 12)
            .foregroundColor(.clear)
//            .fill(Color.white)
//            .shadow(radius: 4)
//            .border(Color.black, width: 1)
//            .padding(4)
            .background(vm.selectedIssue == i ? Color.blue.opacity(0.5) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(-12)
//            .padding(4)
//            .border(
//              vm.selectedIssue == i ? Color.blue : Color.clear
//              )
        )
        .onTapGesture {
          withAnimation {
            vm.selectedIssue = i
          }
        }
      }
      /*
      List(vm.issueList.issues, id: \.title) { issue in
        HStack {
          Text(issue.title)
          Spacer()
          Text("\(issue.count)")
        }
        .background(
          vm.selectedIssue == vm.issueList.issues.firstIndex(where: { $0.title == issue.title }) ? Color.blue : Color.clear
        )
        .onTapGesture {
          vm.selectedIssue = vm.issueList.issues.firstIndex(where: { $0.title == issue.title })
        }
      }
       */
      .listStyle(.plain)
      .padding(.horizontal, 8)

      if vm.changed {
        HStack(spacing: 20) {
          Button("Cancel", role: .destructive) {
            Task {
              try? await vm.load(user: user)
              vm.changed = false
            }
          }

          Button("Save") {
            Task {
              await vm.save(user: user)
              vm.changed = false
            }
          }
        }
        .buttonStyle(.bordered)
        .font(.title)
        .padding()
      }
    }
    .overlay {
      if showHelp {
        HelpView(showHelp: $showHelp)
      }
    }
    .overlay {
      if vm.saving {
        ProgressView()
      }
    }
    .onChange(of: vm.points) { oldVal, newVal in
      vm.changed = true
    }
    .task {
      do {
        try await vm.load(user: user)
      } catch {
        print("Error loading issues: \(error)")
      }
    }
//    .onChange(of: vm.selectedIssue) { oldVal, newVal in
////      print("Selected: \(vm.selectedIssue ?? -1)")
//      selectedIssue = vm.selectedIssue ?? -1
//    }
  }
}

#Preview {
  MyIssuesView(user: BHUser(user: nil, age: 25, gender: "Male", state: "CA"))
    .preferredColorScheme(.dark)
}
