//
//  MasterVC.swift
//  app
//
//  Created by Pradeep Singh on 10/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import UIKit
import Growlytics

class MasterVC: UIViewController {

    @IBOutlet weak var tblVwList: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblVwList.tableFooterView = UIView()
        self.title = "Gorwlytics"
    }
    
    @IBAction func logoutAction(_ sender: UIBarButtonItem) {
        Analytics.getInstance().logoutUser()
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        let customerAttribute: [String:Any]  = [
            "Product ID": 1337,
            "Price": 39.80,
            "Quantity": 1,
            "Product": "Givenchy Pour Homme Cologne",
            "Category": "Fragrance",
            "Currency": "USD",
            "Is Premium": true
        ]
        Analytics.getInstance().updateCustomer(customerAttribute)
    }
    
    @IBAction func addButtonAction(_ sender: UIButton) {
        
        //MARK:- Login Event Track
        let loginAttribute: [String:Any]  = [
            "Product ID": 1337,
            "Price": 39.80,
            "Quantity": 1,
            "Product": "Givenchy Pour Homme Cologne",
            "Category": "Fragrance",
            "Currency": "USD",
            "Is Premium": true
        ]
        
        Analytics.getInstance().loginUser("Custome_ID", loginAttribute)
        
    }
}


extension MasterVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        cell.textLabel!.text =  "Item\(indexPath.row+1)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        debugPrint("Dummy App \(indexPath.row + 1)", "Clicked on list item, lets track this")
        
        let eventAttribute: [String:Any]  = [
            "Product ID": 1337,
            "Price": 39.80,
            "Quantity": 1,
            "Product": "Givenchy Pour Homme Cologne",
            "Category": "Fragrance",
            "Currency": "USD",
            "Is Premium": true
        ]
        Analytics.getInstance().track("User_Custom_Event", eventAttribute)

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        vc.index = indexPath.row + 1
        self.navigationController?.pushViewController(vc, animated: true )
    }
}


