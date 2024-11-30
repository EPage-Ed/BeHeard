//
//  ContentView.swift
//  BeHeard
//
//  Created by Edward Arenberg on 11/15/24.
//

import SwiftUI
import CodeScanner
import Observation

final class Model: ObservableObject {
  @Published var status: LicenseStatus = .none
  @Published var url: URL?
  
  func loadUrl(license: License) {
    let url = URL(string: "https://www.google.com")
    self.url = url
  }
}


struct ContentView: View {
  @StateObject private var model = Model()
  @StateObject private var authVM = AuthViewModel()
  @State private var isPresentingScanner = false
  @State private var scannedCode: String?
  @State private var license = License(code: "")
  @State private var showInfo = false
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    ZStack {
      Color.black
      //      Rectangle()
      //        .fill(Color.black)
        .ignoresSafeArea()
        .overlay(
          Image("honeycomb")
            .resizable()
          //            .aspectRatio(contentMode: .fill)
            .scaledToFill()
            .opacity(0.4)
        )
        .ignoresSafeArea()
      switch model.status {
      case .none:
        VStack {
          Text("Be Heard").font(.system(size: 64, weight: .bold, design: .rounded))
            .foregroundStyle(.linearGradient(colors: [.red,(colorScheme == .light ? .gray : .white),.blue], startPoint: .leading, endPoint: .trailing))
            .padding()
          VStack {
            Text("What's important to you?")
            Text("Make your voice heard!")
          }
          .font(.footnote)
          .foregroundStyle(Color.white)
          HStack {
            Image(systemName: "megaphone.fill")
              .resizable()
              .frame(width: 120, height: 120)
              .foregroundStyle(Color.orange)
          }
          Spacer()
          Button("Scan License") {
//            model.status = .active // .scanning
            model.status = .scanned // .scanning
            isPresentingScanner = true
          }
          .buttonStyle(.borderedProminent)
          .cornerRadius(25.0)
          .font(.largeTitle).bold()
          .tint(.black)
          //            .tint(colorScheme == .dark ? .clear : .black)
          .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .leading, endPoint: .trailing))
          .overlay {
            RoundedRectangle(cornerRadius: 25.0)
              .fill(Color.clear)
              .strokeBorder(Color.white, lineWidth: 2)
            //              .background(.ultraThinMaterial)
          }
          .padding()
          Image("idCalmed")
            .padding()
          Spacer()
          Button("", systemImage: "info.circle") {
            withAnimation(.easeInOut(duration: 1)) {
              showInfo.toggle()
            }
          }
          .font(.largeTitle).bold()
        }
      case .scanning:
        ProgressView()
      case .scanned:
        ProgressView()
        //          Text("Scanned")
      case .underage:
        Text("Underage")
      case .verifying:
        Text("Verifying")
      case .active:
//        Text("Active")
        TabView {
          if authVM.bhUser != nil {
            MyIssuesView(user: authVM.bhUser!)
              .tabItem {
                Label("Vote", systemImage: "checkmark.square")
              }
          }
          ReviewView()
            .tabItem {
              Label("Review", systemImage: "chart.bar")
            }
          InvolvedView()
            .tabItem {
              Label("Involved", systemImage: "globe")
            }
        }
      case .moreinfo:
        Text("More Info")
      case .inactive:
        Text("Inactive")
      }
      
    }
//    .ignoresSafeArea()
//    .padding()
    /*
    .background {
      Color.black
//      Rectangle()
//        .fill(Color.black)
        .ignoresSafeArea()
        .overlay(
          Image("honeycomb")
            .resizable()
//            .aspectRatio(contentMode: .fill)
            .scaledToFill()
            .opacity(0.4)
        )
      /*
      ZStack {
        Rectangle()
          .fill(Color.black)
        //        .background(.ultraThinMaterial)
          .ignoresSafeArea()
        Image("honeycomb")
          .resizable()
          .scaledToFill()
          .opacity(0.4)
          .ignoresSafeArea()
      }
       */
    }
     */
    .overlay {
      if showInfo {
        InfoView(showInfo: $showInfo)
          .padding()
      }
    }

    .preferredColorScheme(.dark)
    .onChange(of: model.status) { oldVal, newVal in
      print("Status: \(oldVal) -> \(newVal)")
      if newVal == .scanned {
        model.loadUrl(license: license)
      }
    }
    .onChange(of: authVM.user) { oldVal, newVal in
      print("Login")
      if newVal != nil {
        model.status = .active
      }
    }
    .onChange(of: authVM.errorMessage) { oldVal, newVal in
      print("Error")
      if let error = newVal {
        model.status = .moreinfo
      }
    }
    .sheet(isPresented: $isPresentingScanner) {
      CodeScannerView(codeTypes: [.pdf417]) { response in
        if case let .success(result) = response {
          license = License(code: result.string)
          scannedCode = result.string
          print(license.dict)
          if license.canVote {
            model.status = .scanned
            let email = license.idNum + "@beheard.com"
            let password = license.dob.formatted(date: .numeric, time: .omitted) + license.zip
            Task {
              await authVM.signIn(email: email, password: password)
              authVM.bhUser = BHUser(user: authVM.user!, age: license.ageYears, gender: license.gender, state: license.state)
//              IssueVote.generateVotes(count: 100)
            }
            //            model.status = .scanned
            //            model.loadUrl(license: license)
          } else {
            model.status = .underage
          }
          //          model.status = .scanned
          //          model.loadUrl(license: license)
          isPresentingScanner = false
        }
      }
    }
  }
}


#Preview {
  ContentView()
}
