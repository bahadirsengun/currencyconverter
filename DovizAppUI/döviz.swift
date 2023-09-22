//
//  döviz.swift
//  DovizAppUI
//
//  Created by Bahadır Sengun on 22.09.2023.
//

import Foundation

struct CurrencyRate: Codable {
    let code: String
    let rate: Double
}

struct CurrencyRatesResponse: Codable {
    let success: Bool
    let result: CurrencyRatesResult
}

struct CurrencyRatesResult: Codable {
    let base: String
    let data: [CurrencyRate]
}

func fetchCurrencyRates(completion: @escaping (CurrencyRatesResult?) -> Void) {
    let headers = [
        "content-type": "application/json",
        "authorization": "apikey 2gQqHP3l4H6GRlIEIWCKUj:1BI1NMa6hq7rg0HWsefx2c"
    ]

    let request = NSMutableURLRequest(url: NSURL(string: "https://api.collectapi.com/economy/currencyToAll?int=10&base=USD")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                        timeoutInterval: 10.0)
    request.httpMethod = "GET"
    request.allHTTPHeaderFields = headers

    let session = URLSession.shared
    let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, _, error) -> Void in
        if let error = error {
            print("API Hatası: \(error.localizedDescription)")
            completion(nil)
        } else {
            if let data = data {
                do {
                    let currencyRatesResponse = try JSONDecoder().decode(CurrencyRatesResponse.self, from: data)
                    completion(currencyRatesResponse.result)
                } catch {
                    print("API Veri Analiz Hatası: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    })

    dataTask.resume()
}


