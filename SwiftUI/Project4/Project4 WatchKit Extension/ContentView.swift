//
//  ContentView.swift
//  Project4 WatchKit Extension
//
//  Created by Paul Hudson on 07/10/2020.
//

import SwiftUI

struct ContentView: View {
    @State private var amount = 500.0
    @State private var selectedCurrency = "USD"
    @State private var amountFocused = false

    static let selectedCurrenciesKey = "SelectedCurrencies"
    static let defaultCurrencies = ["USD", "EUR"]

    static let currencies = ["USD", "AUD", "CAD", "CHF", "CNY", "EUR", "GBP", "HKD", "JPY", "SGD"]

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Text("\(Int(amount))")
                    .font(.system(size: 52))
                    .padding()
                    .frame(width: geo.size.width)
                    .contentShape(Rectangle())
                    .focusable { amountFocused = $0 }
                    .digitalCrownRotation($amount, from: 0, through: 1000, by: 20, sensitivity: .high, isContinuous: false, isHapticFeedbackEnabled: true)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(amountFocused ? Color.green : Color.white, lineWidth: 1)
                    )
                    .padding(.bottom)

                HStack {
                    Picker("Select a currency", selection: $selectedCurrency) {
                        ForEach(Self.currencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }
                    .labelsHidden()

                    NavigationLink(destination: ResultsView(amount: amount, baseCurrency: selectedCurrency)) {
                        Text("Go")
                    }
                    .frame(width: geo.size.width * 0.4)
                }
                .frame(height: geo.size.height / 3)
            }
            .navigationTitle("WatchFX")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
