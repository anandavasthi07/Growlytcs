//
//  DetailVC.swift
//  app
//
//  Created by Pradeep Singh on 10/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import UIKit
import Growlytics

class DetailVC: UIViewController {
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    
    var index : Int!
    private let strDummy = "More details information here."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Item \(index!)"
        self.lblHeader.text = "Details About Item : \(index!)"
        
        var text = ""
        for _ in 0...index {
            if text.isEmpty {
                text = self.strDummy
            } else {
                text += "\n\(self.strDummy)"
            }
        }
        self.lblDetail.text = text
        
        let barButton = UIBarButtonItem.init(title: "Message", style: .plain, target: self, action: #selector(self.messageBtnAction))
        self.navigationItem.rightBarButtonItem = barButton
        
        
        var tempDict = [String: Any]()
        tempDict["Amount"] = 1000.87
        tempDict["Brand"] = "xyz"
        tempDict["Category"] = "Electronics"
        tempDict["Sub Category"] = "ABC"
        Analytics.getInstance().track("Product Viewed", tempDict)
    }
    
    @objc func messageBtnAction(barButton:UIBarButtonItem){
        let alertController = UIAlertController(title: nil,
                                                message: "Replace with your own action",
                                                preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(defaultAction)
        alertController.popoverPresentationController?.barButtonItem = barButton
        self.present(alertController, animated: true, completion: nil)
    }
}
