//
//  CurrenciesView.swift
//  Project4 Watch App
//
//  Created by Paul Hudson on 07/10/2022.
//

import SwiftUI

struct CurrenciesView: View {
    @State private var selectedCurrencies = UserDefaults.standard.stringArray(forKey: ContentView.selectedCurrenciesKey) ?? ContentView.defaultCurrencies
    
    let selectedColor = Color(red: 0, green: 0.55, blue: 0.25)
    let deselectedColor = Color(red: 0.3, green: 0, blue: 0)
    
    var body: some View {
        NavigationStack {
            List(ContentView.currencies, id: \.self) { currency in
                Button(currency) {
                    toggle(currency)
                }
                .listItemTint(selectedCurrencies.contains(currency) ? selectedColor : deselectedColor)
            }
            .listStyle(.carousel)
            .navigationTitle("Currencies")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func toggle(_ currency: String) {
        if let index = selectedCurrencies.firstIndex(of: currency) {
            // if the currency was found in our selected currencies, remove it
            selectedCurrencies.remove(at: index)
        } else {
            // otherwise add it
            selectedCurrencies.append(currency)
        }

        // save the new selected currencies
        UserDefaults.standard.set(selectedCurrencies, forKey: ContentView.selectedCurrenciesKey)
    }
}

struct CurrenciesView_Previews: PreviewProvider {
    static var previews: some View {
        CurrenciesView()
    }
}
