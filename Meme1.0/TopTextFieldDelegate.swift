//
//  TopTextFieldDelegate.swift
//  MemeFirstVersion
//
//  Created by Administrator on 24.01.21.
//

import UIKit
import Foundation

class TopTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

