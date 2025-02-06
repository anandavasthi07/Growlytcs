//
//  EmployeeListView.swift
//  SampleAppSwiftUI
//
//  Created by Apple on 06/02/25.
//  Copyright © 2025 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import SwiftUI
struct EmployeeListView: View {
    @StateObject private var viewModel = EmployeeViewModel()  // ViewModel instance
    
    @State private var showingAddEmployeeView = false // To show Add Employee view
    @EnvironmentObject var viewModelAuthentication: AuthenticationViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.employees) { employee in
                NavigationLink(destination: EmployeeDetailView(employee: employee).onAppear {
                    viewModel.growCustomEvent(name: "Viewed Employee", employee: employee)
                }) {
                    
                    VStack(alignment: .leading) {
                        Text(employee.name)
                            .font(.headline)
                        Text(employee.position)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Employees")
            .navigationBarItems(leading:  Button(action: {
                //showingAddEmployeeView.toggle()  // Show Add Employee form
                viewModelAuthentication.signOut()
            }) {
                Text("Logout")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
            }, trailing: Button(action: {
                showingAddEmployeeView.toggle()  // Show Add Employee form
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            })
            .sheet(isPresented: $showingAddEmployeeView) {
                AddEmployeeView(viewModel: viewModel, isPresented: $showingAddEmployeeView)
            }
        }
    }
}



#Preview {
    EmployeeListView()
}
