//
//  TrackEventViewController.swift
//  Example
//
//  Created by Dominik Hadl on 07/06/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import UIKit
import SendsaySDK
import DropDown

class TrackEventViewController: UIViewController, UITextFieldDelegate {

    private let DEFAULT_EVENT_TYPE = "event_name"
    private let DEFAULT_PROP_KEY = "property"

    @IBOutlet var eventTypeField: UITextField!

    @IBOutlet var keyField1: UITextField!
    @IBOutlet var valueField1: UITextField!
    @IBOutlet var ddButton1: UIButton!
    @IBOutlet var copySwitch1: UISwitch!

    @IBOutlet var keyField2: UITextField!
    @IBOutlet var valueField2: UITextField!
    @IBOutlet var ddButton2: UIButton!
    @IBOutlet var copySwitch2: UISwitch!

    @IBOutlet var keyField3: UITextField!
    @IBOutlet var valueField3: UITextField!
    @IBOutlet var ddButton3: UIButton!
    @IBOutlet var copySwitch3: UISwitch!
    
    var menu1 = DropDown()
    var menu2 = DropDown()
    var menu3 = DropDown()
    
    let actionsToImages = [
        "set" : "plus.app",
        "update" : "square.and.pencil",
        "insert" : "square.and.arrow.down.on.square.fill",
        "merge" : "arrow.merge",
        "merge_update" : "long.text.page.and.pencil",
        "merge_insert" : "pencil.and.list.clipboard",
        "push" : "square.and.arrow.up",
        "unshift" : "list.bullet.indent",
        "delete" : "eraser"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        let dropDownView1 = UIView(frame: ddButton1.frame)
        let dropDownView2 = UIView(frame: ddButton2.frame)
        let dropDownView3 = UIView(frame: ddButton3.frame)

        menu1.anchorView = ddButton1
        menu2.anchorView = ddButton2
        menu3.anchorView = ddButton3

        menu1.textColor = .white
        menu2.textColor = .white
        menu3.textColor = .white

        menu1.dataSource = Array(actionsToImages.keys)
        menu2.dataSource = Array(actionsToImages.keys)
        menu3.dataSource = Array(actionsToImages.keys)
        menu1.cellNib = UINib(nibName: "DropDownCell", bundle: nil)
        menu2.cellNib = UINib(nibName: "DropDownCell", bundle: nil)
        menu3.cellNib = UINib(nibName: "DropDownCell", bundle: nil)

        menu1.customCellConfiguration = { index, title, cell in
            guard let cell = cell as? MyCell else {
                return
            }
            cell.myImageView.image = UIImage(systemName: self.actionsToImages[title] ?? self.actionsToImages.first!.value)
        }
        menu2.customCellConfiguration = { index, title, cell in
            guard let cell = cell as? MyCell else {
                return
            }
            cell.myImageView.image = UIImage(systemName: self.actionsToImages[title] ?? self.actionsToImages.first!.value)
        }
        menu3.customCellConfiguration = { index, title, cell in
            guard let cell = cell as? MyCell else {
                return
            }
            cell.myImageView.image = UIImage(systemName: self.actionsToImages[title] ?? self.actionsToImages.first!.value)
        }
        /// Fixes overlapping by modal window
        if let window = UIApplication.shared.windows.first {
            window.addSubview(dropDownView1)
            window.addSubview(dropDownView2)
            window.addSubview(dropDownView3)
        }

        menu1.selectionAction = { index, title in
            print("Title!")
            self.ddButton1.setTitle(title, for: .normal)
        }
        menu2.selectionAction = { index, title in
            self.ddButton2.setTitle(title, for: .normal)
        }
        menu3.selectionAction = { index, title in
            self.ddButton3.setTitle(title, for: .normal)
        }


        eventTypeField.placeholder = "default = \"\(DEFAULT_EVENT_TYPE)\""
        keyField1.placeholder = "default = \"\(DEFAULT_PROP_KEY)\""
        keyField2.placeholder = "custom_key_2"
        keyField3.placeholder = "custom_key_3"

        SegmentationManager.shared.addCallback(
            callbackData: .init(
                category: .discovery(),
                isIncludeFirstLoad: true,
                onNewData: { segments in
            print(segments)
        }))
    }

    @IBAction func showDropDown1(_ sender: Any) {
        print("Tapped!")
        menu1.show()
    }
    @IBAction func showDropDown2(_ sender: Any) {
        menu2.show()
    }
    @IBAction func showDropDown3(_ sender: Any) {
        menu3.show()
    }


    @IBAction func hideKeyboard() {
        print("Tapped!")
        view.endEditing(true)
    }

    @IBAction func cancelPressed() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func trackPressed(_ sender: Any) {
        let eventType: String = {
            if let text = eventTypeField.text, !text.isEmpty {
                return text
            }
            return DEFAULT_EVENT_TYPE
        }()

        var properties: [String: JSONConvertible] = [:]
        var memberSet: [String: JSONConvertible] = [:]
        var datakey: [[String]] = []

        if let value1 = valueField1.text, !value1.isEmpty {
            var key1 = keyField1.text ?? DEFAULT_PROP_KEY
            if key1.isEmpty {
                key1 = DEFAULT_PROP_KEY
            }
            properties[key1] = value1
        }

        if let key2 = keyField2.text, !key2.isEmpty {
            properties[key2] = valueField2.text ?? ""
        }

        if let key3 = keyField3.text, !key3.isEmpty {
            properties[key3] = valueField3.text ?? ""
        }

//        memberSet["datakey"] = jsonToString(json: datakey)
//        properties["member_set"] = jsonToString(json: memberSet.jsonValue)
        
        
//        print("props_member.set: \(jsonToString(json: properties.jsonValue))")


//        properties["testdictionary"] = ["key1": "value1", "key2": 2, "key3": true]
//        properties["testarray"] = [123, "test", false]

//        Sendsay.shared.trackEvent(properties: properties, timestamp: nil, eventType: eventType)
        dismiss(animated: true, completion: nil)
    }
}
