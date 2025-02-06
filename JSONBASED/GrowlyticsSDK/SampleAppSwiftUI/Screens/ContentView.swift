//
//  ContentView.swift
//  SampleAppSwiftUI
//
//  Created by Apple on 05/02/25.
//  Copyright © 2025 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel

    var body: some View {
        switch viewModel.state {
          case .signedIn: EmployeeListView()
          case .signedOut: SignInScreenView()
        }
    }
}

struct PrimaryButton: View {
    var title: String
    var onTap: ()-> Void
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue)
            .cornerRadius(50)
            .onTapGesture {
                onTap()
            }
    }
}

#Preview {
    ContentView()
}
