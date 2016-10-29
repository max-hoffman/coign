//
//  CharityPickerController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/28/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class CharityPickerController: UIViewController {

    //outlets
    @IBOutlet weak var charityPreferencePicker: UIPickerView!

    //properties
    let charities = Charities.list

    
    override func viewDidLoad() {
        super.viewDidLoad()
        charityPreferencePicker.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK: - Picker view extensions
extension CharityPickerController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //initialize picker view at the first real entry
    func preparePickerView() {
        charityPreferencePicker.selectRow(1, inComponent: 0, animated: false)
    }
    
    //only one section
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //data is in the Constants file
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Charities.list.count
    }
    
    //fill the rows with charity data
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = Charities.list[row]
        if row == 0 {
            return NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 10.0)!,NSForegroundColorAttributeName: UIColor.lightGray])
        }
        return NSAttributedString(string: titleData)
    }
    
    //prevent user from selecting the grey label
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            charityPreferencePicker.selectRow(1, inComponent: 0, animated: true)
        }
    }
}
