//
//  EmployeeViewModel.swift
//  SampleAppSwiftUI
//
//  Created by Apple on 06/02/25.
//  Copyright © 2025 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import Growlytics

struct Employee: Identifiable {
    var id: String = ""
    var name: String
    var position: String
    var salary: String = ""
    var dofJoining: String = ""
    let currency: String = "INR"

    // The initializer
    init( name: String, position: String) {
        self.name = name
        self.position = position
        
        // Generate random salary and date of joining after all properties are initialized
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2020, month: 1, day: 1))! // Jan 1, 2020
        let endDate = calendar.date(from: DateComponents(year: 2024, month: 12, day: 31))! // Dec 31, 2024
        let date = generateRandomDateOfJoining(startDate: startDate, endDate: endDate)
        self.id = self.generateRandomEmpID()
        self.salary = "\(generateRandomSalary())" // Generate random salary
        self.dofJoining = formattedDate(date) // Format the date of joining
    }
    
    // Function to generate random salary
    func generateRandomSalary(min: Int = 500000, max: Int = 3000000) -> Int {
        return Int.random(in: min...max)
    }
    
    func generateRandomEmpID(min: Int = 1000, max: Int = 10000) -> String {
        let intId = Int.random(in: min...max)
        return "GRW\(intId)"
    }
    // Function to generate a random date of joining
    func generateRandomDateOfJoining(startDate: Date, endDate: Date) -> Date {
        let timeInterval = endDate.timeIntervalSince(startDate)
        let randomInterval = TimeInterval(arc4random_uniform(UInt32(timeInterval)))
        return startDate.addingTimeInterval(randomInterval)
    }

    // Function to format the date of joining
    func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
}

class EmployeeViewModel: ObservableObject {
    @Published var employees: [Employee] = [
        Employee(name: "Ravi", position: "Software Engineer"),
        Employee(name: "Shubham", position: "Product Manager")
    ]
    
    // Add a new employee to the list
    func addEmployee(name: String, position: String) {
        let newEmployee = Employee(name: name, position: position)
        employees.append(newEmployee)

        self.growCustomEvent(name: "Added_Employee_Event", employee: newEmployee)
    }
    
    func growCustomEvent(name: String, employee: Employee) {
        
        let eventAttribute: [String:Any]  = [
            "Employee ID": employee.id,
            "Salary": employee.salary,
            "DOJ": employee.dofJoining,
            "Name": employee.name,
            "Position": employee.position,
            "Currency": employee.currency
        ]
        Analytics.getInstance().track(name, eventAttribute)
    }

}
