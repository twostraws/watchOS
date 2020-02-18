//
//  ContentView.swift
//  Project1 WatchKit Extension
//
//  Created by Paul Hudson on 18/02/2020.
//  Copyright © 2020 Paul Hudson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var amount = 500.0
    @State private var selectedCurrency = "USD"
    @State private var amountFocused = false

    static let currencies = ["USD", "AUD", "CAD", "CHF", "CNY", "EUR", "GBP", "HKD", "JPY", "SGD"]
    static let selectedCurrenciesKey = "SelectedCurrencies"
    static let defaultCurrencies = ["USD", "EUR"]

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Text("\(Int(self.amount))")
                    .font(.system(size: 52))
                    .padding()
                    .frame(width: geo.size.width)
                    .contentShape(Rectangle())
                    .focusable { self.amountFocused = $0 }
                    .digitalCrownRotation(self.$amount, from: 0, through: 1000, by: 20, sensitivity: .high, isContinuous: false, isHapticFeedbackEnabled: true)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(self.amountFocused ? Color.green : Color.white, lineWidth: 1)
                    )
                    .padding(.bottom)

//                Commented out so you can use the Digital Crown approach.
//                Slider(value: self.$amount, in: 0...1000, step: 20)
//                    .frame(height: geo.size.height / 3)
//                    .accentColor(Color.green)
                

                HStack {
                    Picker(selection: self.$selectedCurrency, label: EmptyView()) {
                        ForEach(Self.currencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }

                    NavigationLink(destination: ResultsView(amount: self.amount, baseCurrency: self.selectedCurrency)) {
                        Text("Go")
                    }
                    .frame(width: geo.size.width * 0.4)
                }
                .frame(height: geo.size.height / 3)
            }
        }
        .navigationBarTitle("WatchFX")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
