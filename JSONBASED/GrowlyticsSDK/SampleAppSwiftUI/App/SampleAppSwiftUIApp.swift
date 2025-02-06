//
//  SampleAppSwiftUIApp.swift
//  SampleAppSwiftUI
//
//  Created by Apple on 05/02/25.
//  Copyright © 2025 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import SwiftUI
import FirebaseCore

@main
struct SampleAppSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var viewModel = AuthenticationViewModel()

    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
