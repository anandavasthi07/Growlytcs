//
//  EmployeeDetailView.swift
//  SampleAppSwiftUI
//
//  Created by Apple on 06/02/25.
//  Copyright © 2025 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation
import SwiftUI

struct EmployeeDetailView: View {
    // Employee details (passed in as an example)
    let employee: Employee
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Employee Details")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Divider()
            
            HStack {
                Text("Employee ID:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(employee.id)
                    .font(.body)
            }
            
            HStack {
                Text("Name:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(employee.name)
                    .font(.body)
            }
            
            HStack {
                Text("Position:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(employee.position)
                    .font(.body)
            }
            
            HStack {
                Text("Salary:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("₹\(employee.salary)")
                    .font(.body)
            }
            
            HStack {
                Text("Date of Joining:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(employee.dofJoining)
                    .font(.body)
            }
            
            HStack {
                Text("Currency:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(employee.currency)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Employee Info", displayMode: .inline)
    }
}
