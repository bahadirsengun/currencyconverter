import Foundation

struct CurrencyConverter {
    private let apiKey = "apikey 2gQqHP3l4H6GRlIEIWCKUj:1BI1NMa6hq7rg0HWsefx2c"

    func convertCurrency(amount: Double, fromCurrency: String, toCurrency: String, completion: @escaping (Double?) -> Void) {
        guard let apiUrl = URL(string: "https://api.collectapi.com/economy/exchange?int=\(amount)&to=\(toCurrency)&base=\(fromCurrency)") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "authorization")

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("API Hatası: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let result = json?["result"] as? [String: Any], let data = result["data"] as? [[String: Any]] {
                        if let firstCurrencyData = data.first,
                           let rate = firstCurrencyData["rate"] as? String,
                           let rateValue = Double(rate) {
                            let convertedAmount = amount * rateValue
                            completion(convertedAmount)
                        } else {
                            print("API Veri Analiz Hatası")
                            completion(nil)
                        }
                    } else {
                        print("API Veri Analiz Hatası")
                        completion(nil)
                    }
                } catch {
                    print("API Veri Analiz Hatası: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }

        dataTask.resume()
    }
}
