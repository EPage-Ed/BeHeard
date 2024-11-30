//
//  InvolvedView.swift
//  BeHeard
//
//  Created by Edward Arenberg on 11/16/24.
//

import SwiftUI

struct InvolvedView: View {
  @Environment(\.openURL) var openURL
  private var sites : [(String,String)] = [
    ("Getting Involved","https://www.sos.ca.gov/promote-vote-ca/getting-involved"),
    ("Voting / Volunteering","https://lacity.gov/AngelenoConnect/OnlineServices/OnlineDirectory/Voting-Volunteering-Getting-Involved"),
    ("How to Get Involved","https://careerdesignstudio.buffalo.edu/blog/2023/04/28/how-to-get-involved-in-politics-6-methods-of-political-engagement/"),
    ("Working on Political Campaigns","https://hls.harvard.edu/bernard-koteen-office-of-public-interest-advising/a-quick-guide-to-working-on-political-campaigns/"),
    ("Local Politics","https://careerdesignstudio.buffalo.edu/blog/2024/04/16/how-to-get-involved-in-local-politics/"),
    ("Youth Involvement","https://www.bgca.org/news-stories/2024/May/ways-to-get-young-people-involved-in-elections/"),
    ("Voting and Elections","https://www.usa.gov/voting-and-elections"),

  ]
  var body: some View {
    VStack {
      Text("Get Involved")
        .font(.title)
        .padding()
      List {
        ForEach(sites, id: \.0) { site in
          Link(site.0, destination: URL(string:site.1)!)
            .font(.title)
            .foregroundStyle(.linearGradient(colors: [.red,.blue], startPoint: .leading, endPoint: .trailing))
//            .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
//          NavigationLink(destination: Text(site.1)) {
//            Text(site.0)
//          }
        }
      }
      .listRowSpacing(20)
    }
  }
}

#Preview {
  InvolvedView()
}
