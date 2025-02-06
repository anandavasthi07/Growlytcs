//
//  Logger.swift
//  Growlytics
//
//  Created by Pradeep Singh on 04/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

final class Logger {
    private var enabled = false
    
    static let instance = Logger()
    
    func setEnabled(_ isEnabled : Bool) {
        self.enabled = isEnabled
    }
    
    //MARK: *************************** Warn Methods *******************************/
    
    func error(message : String) {
        if self.enabled {
            print("Growlytics \(Thread.current) :-", message)
        }
    }
    
    func error(suffix : String , message : String) {
        if self.enabled {
            print("Growlytics \(suffix) \(Thread.current) :-", message)
        }
    }
    
    func error(suffix : String , message : String , error : Error? = nil ) {
        if self.enabled {
            print("Growlytics \(suffix) \(Thread.current) :-", message, error as Any)
        }
    }
    
    func error(message : String , error : Error? = nil) {
        if self.enabled {
            print("Growlytics \(Thread.current) :-", message, error as Any)
        }
    }
    
    //MARK: ************************* Warn Methods ******************************/
    
    func warn(message : String ) {
        if self.enabled {
            print("Growlytics \(Thread.current) :-", message)
        }
    }
    
    func warn(suffix : String , message : String ) {
        if self.enabled {
            print("Growlytics \(suffix) \(Thread.current) :-", message)
        }
    }
    
    func warn(suffix : String , message : String , error : Error? = nil) {
        if self.enabled {
            print("Growlytics \(suffix) \(Thread.current) :-", message, error as Any)
           
        }
    }
    
    func warn(message : String , error : Error? = nil) {
        if self.enabled {
            print("Growlytics  \(Thread.current) :-", message, error as Any)
        }
    }
    
    //MARK: *************************** Debug Methods ****************************/
    
    func debug(message : String ) {
        if self.enabled {
            print("Growlytics \(Thread.current) :-", message)
        }
    }
    
    func debug(suffix : String , message : String ) {
        if self.enabled {
            print("Growlytics \(suffix) \(Thread.current) :-", message)
        }
    }
    
    func debug(suffix : String , message : String , error : Error? = nil) {
        if self.enabled {
            print("Growlytics \(suffix) \(Thread.current) :-", message, error as Any)
        }
    }
    
    func debug(message : String , error : Error? = nil) {
        if self.enabled {
            print("Growlytics  \(Thread.current) :-", message, error as Any)
        }
    }
    
    //MARK: ********************* Info Methods **************************/
    
    func info(message : String ) {
        if self.enabled {
            print("Growlytics \(Thread.current) :-", message)
        }
    }
    
    func info(suffix : String , message : String ) {
        if self.enabled {
            print("Growlytics \(suffix) \(Thread.current) :-", message)
        }
    }
    
    func info(suffix : String , message : String , error : Error? = nil) {
        if self.enabled {
            print("Growlytics \(suffix) \(Thread.current) :-", message, error as Any)
        }
    }
    
    func info(message : String , error : Error? = nil) {
        if self.enabled {
            print("Growlytics  \(Thread.current) :-", message, error as Any)
        }
    }
}
