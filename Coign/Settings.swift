//
//  Settings.swift
//  Coign
//
//  Created by Maximilian Hoffman on 1/28/17.
//  Copyright © 2017 Exlent Studios. All rights reserved.
//
//  Created by Ben Guo on 6/17/16.
//  Copyright © 2016 Stripe. All rights reserved.
//

import UIKit
import Stripe

struct Settings {
    let theme: STPTheme
    let additionalPaymentMethods: STPPaymentMethodType
    let requiredBillingAddressFields: STPBillingAddressFields
    let smsAutofillEnabled: Bool
}

class SettingsViewController: UITableViewController {
    var settings: Settings {
        return Settings(theme: self.theme.stpTheme,
                        additionalPaymentMethods: self.applePay.enabled ? .all : STPPaymentMethodType(),
                        requiredBillingAddressFields: self.requiredBillingAddressFields.stpBillingAddressFields,
                        smsAutofillEnabled: self.smsAutofill.enabled)
    }
    
    private var theme: Theme = .CustomLight
    private var applePay: Switch = .Enabled
    private var requiredBillingAddressFields: RequiredBillingAddressFields = .None
    private var smsAutofill: Switch = .Enabled
    
    fileprivate enum Section: String {
        case Theme = "Theme"
        case ApplePay = "Apple Pay"
        case RequiredBillingAddressFields = "Required Billing Address Fields"
        case SMSAutofill = "SMS Autofill"
        case Session = "Session"
        
        init(section: Int) {
            switch section {
            case 0: self = .Theme
            case 1: self = .ApplePay
            case 2: self = .RequiredBillingAddressFields
            case 3: self = .SMSAutofill
            default: self = .Session
            }
        }
    }
    
    enum Theme: String {
        case Default = "Default"
        case CustomLight = "Custom – Light"
        case CustomDark = "Custom – Dark"
        
        init(row: Int) {
            switch row {
            case 0: self = .Default
            case 1: self = .CustomLight
            default: self = .CustomDark
            }
        }
        
        var stpTheme: STPTheme {
            switch self {
            case .Default:
                return STPTheme.default()
            case .CustomLight:
                let theme = STPTheme()
                theme.primaryBackgroundColor = UIColor(red:0.96, green:0.96, blue:0.95, alpha:1.00)
                theme.secondaryBackgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)
                theme.primaryForegroundColor = UIColor(red:0.35, green:0.35, blue:0.35, alpha:1.00)
                theme.secondaryForegroundColor = UIColor(red:0.66, green:0.66, blue:0.66, alpha:1.00)
                theme.accentColor = UIColor(red:0.09, green:0.81, blue:0.51, alpha:1.00)
                theme.errorColor = UIColor(red:0.87, green:0.18, blue:0.20, alpha:1.00)
                theme.font = UIFont(name: "ChalkboardSE-Light", size: 17)
                theme.emphasisFont = UIFont(name: "ChalkboardSE-Bold", size: 17)
                return theme
            case .CustomDark:
                let theme = STPTheme()
                theme.primaryBackgroundColor = UIColor(red:0.16, green:0.23, blue:0.31, alpha:1.00)
                theme.secondaryBackgroundColor = UIColor(red:0.22, green:0.29, blue:0.38, alpha:1.00)
                theme.primaryForegroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)
                theme.secondaryForegroundColor = UIColor(red:0.60, green:0.64, blue:0.71, alpha:1.00)
                theme.accentColor = UIColor(red:0.98, green:0.80, blue:0.00, alpha:1.00)
                theme.errorColor = UIColor(red:0.85, green:0.48, blue:0.48, alpha:1.00)
                theme.font = UIFont(name: "GillSans", size: 17)
                theme.emphasisFont = UIFont(name: "GillSans", size: 17)
                return theme
            }
        }
    }
    
    fileprivate enum Switch: String {
        case Enabled = "Enabled"
        case Disabled = "Disabled"
        
        init(row: Int) {
            self = (row == 0) ? .Enabled : .Disabled
        }
        
        var enabled: Bool {
            return self == .Enabled
        }
    }
    
    fileprivate enum RequiredBillingAddressFields: String {
        case None = "None"
        case Zip = "Zip"
        case Full = "Full"
        
        init(row: Int) {
            switch row {
            case 0: self = .None
            case 1: self = .Zip
            default: self = .Full
            }
        }
        
        var stpBillingAddressFields: STPBillingAddressFields {
            switch self {
            case .None: return .none
            case .Zip: return .zip
            case .Full: return .full
            }
        }
    }
    
    convenience init() {
        self.init(style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss as (Void) -> Void))
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
}
