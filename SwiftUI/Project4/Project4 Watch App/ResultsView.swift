//
//  ResultsView.swift
//  Project4 Watch App
//
//  Created by Paul Hudson on 07/10/2022.
//

import Combine
import SwiftUI

struct CurrencyResult: Codable {
    let base: String
    let rates: [String: Double]
}

struct ResultsView: View {
    enum FetchState {
        case fetching, success, failed
    }
    
    @State private var fetchState = FetchState.fetching
    @State private var fetchedCurrencies = [(symbol: String, rate: Double)]()
    @State private var request: AnyCancellable?
    
    let amount: Double
    let baseCurrency: String
    
    let appID = "YOUR_APP_ID_HERE"
    
    var body: some View {
        Group {
            if fetchState == .success {
                List(fetchedCurrencies, id: \.symbol) { currency in
                    Text(rate(for: currency))
                }
            } else {
                Text(fetchState == .fetching ? "Fetching…" : "Fetch failed")
            }
        }
        .navigationTitle(amount.formatted(.currency(code: baseCurrency)))
        .onAppear(perform: fetchData)
    }
    
    func parse(result: CurrencyResult) {
        guard result.rates.isEmpty == false else {
            // fetch error!
            fetchState = .failed
            return
        }
            
        // if we're still here, it means the fetch succeeded!
        fetchState = .success
        
        // read the user's selected currencies
        let selectedCurrencies = UserDefaults.standard.stringArray(forKey: ContentView.selectedCurrenciesKey) ?? ContentView.defaultCurrencies
        
        for symbol in result.rates {
            // filter the rates so we only show ones the user cares about
            guard selectedCurrencies.contains(symbol.key) else { continue }
            let rateName = symbol.key
            let rateValue = symbol.value
            fetchedCurrencies.append((symbol: rateName, rate: rateValue))
        }
        
        fetchedCurrencies.sort { $0.symbol < $1.symbol }
    }
    
    func fetchData() {
        guard let url = URL(string: "https://openexchangerates.org/api/latest.json?app_id=\(appID)&base=\(baseCurrency)") else {
            fetchState = .failed
            return
        }
        
        request = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CurrencyResult.self, decoder: JSONDecoder())
            .replaceError(with: CurrencyResult(base: "", rates: [:]))
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: parse)
    }
    
    func rate(for result: (symbol: String, rate: Double)) -> String {
        (amount * result.rate).formatted(.currency(code: result.symbol))
    }
}

#Preview {
    ResultsView(amount: 500, baseCurrency: "USD")
}
