//
//  InterfaceController.swift
//  Project4 WatchKit Extension
//
//  Created by Paul Hudson on 21/03/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var amountLabel: WKInterfaceLabel!
    @IBOutlet var amountSlider: WKInterfaceSlider!
    @IBOutlet var currencyPicker: WKInterfacePicker!

    static let currencies = ["USD", "AUD", "CAD", "CHF", "CNY", "EUR", "GBP", "HKD", "JPY", "SGD"]
    static let defaultCurrencies = ["USD", "EUR"]
    static let selectedCurrenciesKey = "SelectedCurrencies"

    var currentCurrency = "USD"
    var currentAmount = 500

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        var items = [WKPickerItem]()

        for currency in InterfaceController.currencies {
            let item = WKPickerItem()
            item.title = currency
            items.append(item)
        }

        currencyPicker.setItems(items)
    }
    
    @IBAction func convertTapped() {
        let context = ["amount": String(currentAmount), "base": currentCurrency]
        WKInterfaceController.reloadRootPageControllers(withNames: ["Results"], contexts: [context], orientation: .horizontal, pageIndex: 0)
    }

    @IBAction func amountChanged(_ value: Float) {
        currentAmount = Int(value)
        amountLabel.setText(String(currentAmount))
    }

    @IBAction func baseCurrencyChanged(_ value: Int) {
        currentCurrency = InterfaceController.currencies[value]
    }
}
