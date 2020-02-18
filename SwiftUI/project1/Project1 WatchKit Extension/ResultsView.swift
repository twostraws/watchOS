//
//  ResultsView.swift
//  Project1 WatchKit Extension
//
//  Created by Paul Hudson on 18/02/2020.
//  Copyright © 2020 Paul Hudson. All rights reserved.
//

import Combine
import SwiftUI

struct ResultsView: View {
    enum FetchState {
        case fetching, success, failed
    }

    struct CurrencyResult: Codable {
        var base: String
        var rates: [String: Double]
    }

    @State private var fetchState = FetchState.fetching
    @State private var fetchedCurrencies = [(symbol: String, rate: Double)]()
    @State private var request: AnyCancellable?

    var amount: Double
    var baseCurrency: String
    let appID = "_18bac06cd83a405797d73d7b66820925"

    var body: some View {
        Group {
            if fetchState == .success {
                List {
                    ForEach(fetchedCurrencies, id: \.symbol) { currency in
                        Text(self.rate(for: currency))
                    }
                }
            } else {
                Text(fetchState == .fetching ? "Fetching…" : "Fetch failed")
            }
        }
        .onAppear(perform: fetchData)
        .navigationBarTitle("\(Int(amount)) \(baseCurrency)")
    }

    func fetchData() {
        if let url = URL(string: "https://openexchangerates.org/api/latest.json?app_id=\(appID)&base=\(baseCurrency)") {
            request = URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .decode(type: CurrencyResult.self, decoder: JSONDecoder())
                .replaceError(with: CurrencyResult(base: "", rates: [:]))
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: parse)
        }
    }

    func parse(result: CurrencyResult) {
        if result.rates.count == 0 {
            // fetch error!
            fetchState = .failed
        } else {
            // fetch succeeded!
            fetchState = .success

            // read the user's selected currencies
            let selectedCurrencies = UserDefaults.standard.array(forKey: ContentView.selectedCurrenciesKey) as? [String] ?? ContentView.defaultCurrencies

            for symbol in result.rates {
                // filter the rates so we only show ones the user cares about
                guard selectedCurrencies.contains(symbol.key) else { continue }
                let rateName = symbol.key
                let rateValue = symbol.value
                fetchedCurrencies.append((symbol: rateName, rate: rateValue))
            }

            fetchedCurrencies.sort { $0.symbol < $1.symbol }
        }
    }

    func rate(for currency: (symbol: String, rate: Double)) -> String {
        let value = currency.rate * amount
        let rate = String(format: "%.2f", value)
        return "\(currency.symbol) \(rate)"
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(amount: 500, baseCurrency: "USD")
    }
}
