//
//  InfoView.swift
//  BeHeard
//
//  Created by Edward Arenberg on 11/15/24.
//

import SwiftUI

struct InfoView: View {
  @Binding var showInfo: Bool
  
  var body: some View {
    ZStack( alignment: .topTrailing) {
      VStack(spacing: 16) {
        Spacer()
        Text("Tap Scan Card button")
        Text("Scan back of\nState ID Card")
        Text("The info is ***NOT*** stored")
        Text("It is only used to make your voice unique")
          .frame(maxWidth: 320)
        Spacer()
      }
      .padding(.horizontal)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
      .font(.title)
      Button("", systemImage: "xmark.circle") {
        withAnimation(.easeInOut(duration: 1)) {
          showInfo.toggle()
        }
      }
      .font(.title)
      .tint(.red)
      .offset(y: -10)
      .padding(.vertical)
    }
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 25.0))
  }
}

#Preview {
  InfoView(showInfo: .constant(true))
    .preferredColorScheme(.dark)
    
}
