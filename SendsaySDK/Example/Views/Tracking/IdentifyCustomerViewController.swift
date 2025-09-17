//
//  IdentifyCustomerViewController.swift
//  Example
//
//  Created by Dominik Hadl on 07/06/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import UIKit
import SendsaySDK
import DropDown

class IdentifyCustomerViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var idKeyField: UITextField!
    @IBOutlet var idValueField: UITextField!

    @IBOutlet var keyField1: UITextField!
    @IBOutlet var valueField1: UITextView!
    @IBOutlet var ddButton1: UIButton!
    @IBOutlet var copySwitch1: UISwitch!

    @IBOutlet var keyField2: UITextField!
    @IBOutlet var valueField2: UITextView!
    @IBOutlet var ddButton2: UIButton!
    @IBOutlet var copySwitch2: UISwitch!

    @IBOutlet var keyField3: UITextField!
    @IBOutlet var valueField3: UITextView!
    @IBOutlet var ddButton3: UIButton!
    @IBOutlet var copySwitch3: UISwitch!
    
    var activeTextField: UITextField?

    var menu1 = DropDown()
    var menu2 = DropDown()
    var menu3 = DropDown()
    
    let actions = [
        "set",
        "update",
        "insert",
        "merge",
        "merge_update",
        "merge_insert",
        "push",
        "unshift",
        "delete"
    ]
    
    let images = [
        "plus.app",
        "square.and.pencil",
        "square.and.arrow.down.on.square.fill",
        "arrow.merge",
        "long.text.page.and.pencil",
        "pencil.and.list.clipboard",
        "square.and.arrow.up",
        "list.bullet.indent",
        "eraser"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        let dropDownView1 = UIView(frame: ddButton1.frame)
        let dropDownView2 = UIView(frame: ddButton2.frame)
        let dropDownView3 = UIView(frame: ddButton3.frame)

        menu1.anchorView = ddButton1
        menu2.anchorView = ddButton2
        menu3.anchorView = ddButton3
        
        menu1.setupCornerRadius(40.0)
        menu1.layer.masksToBounds = true
        menu3.layer.cornerRadius = 60
        menu3.layer.masksToBounds = true
        
        menu1.textColor = .white
        menu2.textColor = .white
        menu3.textColor = .white

        menu1.dataSource = actions
        menu2.dataSource = actions
        menu3.dataSource = actions
        menu1.cellNib = UINib(nibName: "DropDownCell", bundle: nil)
        menu2.cellNib = UINib(nibName: "DropDownCell", bundle: nil)
        menu3.cellNib = UINib(nibName: "DropDownCell", bundle: nil)

        menu1.customCellConfiguration = { index, title, cell in
            guard let cell = cell as? MyCell else {
                return
            }
            cell.myImageView.image = UIImage(systemName: self.images[index])
        }
        menu2.customCellConfiguration = { index, title, cell in
            guard let cell = cell as? MyCell else {
                return
            }
            cell.myImageView.image = UIImage(systemName: self.images[index])
        }
        menu3.customCellConfiguration = { index, title, cell in
            guard let cell = cell as? MyCell else {
                return
            }
            cell.myImageView.image = UIImage(systemName: self.images[index])
        }
        /// Fixes overlapping by modal window
        if let window = UIApplication.shared.windows.first {
            window.addSubview(dropDownView1)
            window.addSubview(dropDownView2)
            window.addSubview(dropDownView3)
        }

        menu1.selectionAction = { index, title in
            self.ddButton1.setTitle(title, for: .normal)
        }
        menu2.selectionAction = { index, title in
            self.ddButton2.setTitle(title, for: .normal)
        }
        menu3.selectionAction = { index, title in
            self.ddButton3.setTitle(title, for: .normal)
        }


        idKeyField.placeholder = "registered"
        idValueField.placeholder = "ex. email@address.com"

        keyField1.placeholder = "custom_key_1"
        keyField2.placeholder = "custom_key_2"
        keyField3.placeholder = "custom_key_3"

        ddButton1.setTitle(actions[0], for: .normal)
        ddButton2.setTitle(actions[0], for: .normal)
        ddButton3.setTitle(actions[0], for: .normal)

        if let customerIds = CustomerTokenStorage.shared.customerIds,
           let registeredValue = customerIds["registered"] {
            idKeyField.text = "registered"
            idValueField.text = registeredValue
        }
    }

    @IBAction func showDropDown1(_ sender: Any) {
//        print("Tapped!")
        menu1.show()
    }
    @IBAction func showDropDown2(_ sender: Any) {
        menu2.show()
    }
    @IBAction func showDropDown3(_ sender: Any) {
        menu3.show()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }

    @IBAction func hideKeyboard() {
        view.endEditing(true)
    }

    @IBAction func cancelPressed() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func trackPressed(_ sender: Any) {
        let ids: [String: String]?
        if let idKey = idKeyField.text, !idKey.isEmpty,
            let idValue = idValueField.text, !idValue.isEmpty {
            ids = [idKey: idValue]
        } else {
            ids = nil
        }

        var properties: [String: JSONValue] = [:]
        var memberSet: [String: JSONValue] = [:]
        var datakey: [JSONValue] = []

//        if let key1 = keyField1.text, !key1.isEmpty {
//            var mode = ddButton1.title(for: .normal) ?? ""
//            if(copySwitch1.isOn && !mode.isEmpty) {
//                mode += ".copy"
//            }
//
//            datakey.append([key1, mode, valueField1.text ?? "",])
//        }
        if let key1 = keyField1.text, !key1.isEmpty {
            var mode1 = ddButton1.title(for: .normal) ?? ""
            if copySwitch1.isOn, !mode1.isEmpty { mode1 += ".copy" }
            
            if let v1 = valueField1.text, !v1.isEmpty {
                datakey.append(.array([ .string(key1), .string(mode1), .string(v1) ]))
            }
        }

//        if let key2 = keyField2.text, !key2.isEmpty {
//            var mode = ddButton2.title(for: .normal) ?? ""
//            if(copySwitch2.isOn && !mode.isEmpty) {
//                mode += ".copy"
//            }
//
//            datakey.append([key2, mode, valueField2.text ?? "",])
//        }
        if let key2 = keyField2.text, !key2.isEmpty {
            var mode2 = ddButton2.title(for: .normal) ?? ""
            if copySwitch2.isOn, !mode2.isEmpty { mode2 += ".copy" }
            
            if let v2 = valueField2.text, !v2.isEmpty {
                datakey.append(.array([ .string(key2), .string(mode2), .string(v2) ]))
            }
        }

//        if let key3 = keyField3.text, !key3.isEmpty {
//            var mode = ddButton3.title(for: .normal) ?? ""
//            if(copySwitch3.isOn && !mode.isEmpty) {
//                mode += ".copy"
//            }
//
//            datakey.append([key3, mode, valueField3.text ?? "",])
//        }
        if let key3 = keyField3.text, !key3.isEmpty {
            var mode3 = ddButton3.title(for: .normal) ?? ""
            if copySwitch3.isOn, !mode3.isEmpty { mode3 += ".copy" }
            
            if let v3 = valueField3.text, !v3.isEmpty {
                datakey.append(.array([ .string(key3), .string(mode3), .string(v3) ]))
            }
        }

        memberSet["datakey"] = .array(datakey)
        properties["member_set"] = .dictionary(memberSet)

//        print("props_member.set: \(jsonPretty(json: properties))")
        properties["cce"] = .string("test-iOs")

        CustomerTokenStorage.shared.configure(customerIds: ids)
        Sendsay.shared.identifyCustomer(customerIds: ids, properties: properties, timestamp: nil)
        dismiss(animated: true, completion: nil)
    }
}

func jsonPretty(json: Any) -> JSONConvertible{
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        let convertedString = String(data: jsonData, encoding: .utf8) as NSString? ?? ""
        debugPrint(convertedString)
        return convertedString
    } catch let myJSONError {
        print("Error encoding JSON: \(myJSONError)")
        return ""
    }
}
