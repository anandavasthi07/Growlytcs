//
//  AddEmployeeView.swift
//  SampleAppSwiftUI
//
//  Created by Apple on 06/02/25.
//  Copyright © 2025 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import SwiftUI

struct AddEmployeeView: View {
    @ObservedObject var viewModel: EmployeeViewModel
    
    @State private var name = ""
    @State private var position = ""
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Employee Details")) {
                    TextField("Name", text: $name)
                    TextField("Position", text: $position)
                }
                
                Button(action: {
                    viewModel.addEmployee(name: name, position: position)
                    isPresented.toggle()
                }) {
                    Text("Add Employee")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(name.isEmpty || position.isEmpty) // Disable if fields are empty
            }
            .navigationTitle("Add Employee")
            .navigationBarItems(trailing: Button("Done") {
                // Close the sheet
                name = ""
                position = ""
                isPresented.toggle()
            })
        }
    }
}


#Preview {
    AddEmployeeView(viewModel: EmployeeViewModel(), isPresented: .constant(false))
}
