//
//  ResultsView.swift
//  Project4 WatchKit Extension
//
//  Created by Paul Hudson on 07/10/2020.
//

import Combine
import SwiftUI

struct ResultsView: View {
    enum FetchState {
        case fetching, success, failed
    }

    struct CurrencyResult: Codable {
        let base: String
        let rates: [String: Double]
    }

    @State private var fetchState = FetchState.fetching
    @State private var fetchedCurrencies = [(symbol: String, rate: Double)]()
    let appID = "YOUR_APP_ID_HERE"

    @State private var request: AnyCancellable?

    let amount: Double
    let baseCurrency: String

    var body: some View {
        Group {
            if fetchState == .success {
                List {
                    ForEach(fetchedCurrencies, id: \.symbol) { currency in
                        Text(rate(for: currency))
                    }
                }
            } else {
                Text(fetchState == .fetching ? "Fetching…" : "Fetch failed")
            }
        }
        .onAppear(perform: fetchData)
        .navigationTitle("\(Int(amount)) \(baseCurrency)")
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
        if result.rates.isEmpty {
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
