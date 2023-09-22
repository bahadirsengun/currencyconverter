import SwiftUI

struct Islem: Identifiable {
    let id = UUID()
    let metin: String
}

struct ContentView: View {
    @State private var miktar: String = ""
    @State private var kaynakDoviz: Doviz = .usd
    @State private var hedefDoviz: Doviz = .eur
    @State private var sonuc: Double?
    @State private var currencyConverter = CurrencyConverter()
    @State private var gecmisIslemler: [Islem] = []
    @State private var seciliIslem: Islem?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Çevir")) {
                    TextField("Miktar", text: $miktar)
                        .keyboardType(.decimalPad)
                    Picker("Kaynak Döviz", selection: $kaynakDoviz) {
                        ForEach(Doviz.allCases, id: \.self) { doviz in
                            Text(doviz.rawValue)
                        }
                    }
                    Picker("Hedef Döviz", selection: $hedefDoviz) {
                        ForEach(Doviz.allCases, id: \.self) { doviz in
                            Text(doviz.rawValue)
                        }
                    }
                }

                Section(header: Text("Sonuç")) {
                    Text(sonuc != nil ? String(format: "%.2f \(hedefDoviz.rawValue)", sonuc!) : "Sonuç")
                }
                
                Section(header: Text("Geçmiş İşlemler")) {
                    List {
                        ForEach(gecmisIslemler) { islem in
                            Button(action: {
                                seciliIslem = islem
                            }) {
                                Text(islem.metin)
                            }
                        }
                        .onDelete(perform: { indexSet in
                            gecmisIslemler.remove(atOffsets: indexSet)
                        })
                    }
                }
            }
            .navigationBarTitle("Döviz Çevirici")
            .navigationBarItems(trailing:
                Button("Dönüştür") {
                    dovizCevir()
                    hideKeyboard()
                }
            )
        }
        .alert(item: $seciliIslem) { islem in
            return Alert(
                title: Text("İşlemi Sil"),
                message: Text("Aşağıdaki işlemi silmek istiyor musunuz?\n\n\(islem.metin)"),
                primaryButton: .destructive(Text("Sil")) {
                    gecmisIslemler.removeAll { $0.id == islem.id }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func dovizCevir() {
        guard let amount = Double(miktar) else {
            print("Geçersiz miktar")
            return
        }

        currencyConverter.convertCurrency(amount: amount, fromCurrency: kaynakDoviz.rawValue, toCurrency: hedefDoviz.rawValue) { convertedAmount in
                if let convertedAmount = convertedAmount {
                    DispatchQueue.main.async {
                        self.sonuc = convertedAmount
                        let islemMetni = "\(amount) \(kaynakDoviz.rawValue) = \(convertedAmount) \(hedefDoviz.rawValue)"
                        self.gecmisIslemler.append(Islem(metin: islemMetni))
                        
                        // Döviz çevirme işlemi sonrasında miktarı ve sonucu sıfırla
                        self.miktar = ""
                    }
                } else {
                    print("Döviz çevrimi başarısız")
                }
            }
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum Doviz: String, CaseIterable {
    case usd = "USD"
    case eur = "EUR"
    case `try` = "TRY" // Türk Lirası
    case gbp = "GBP"
    case jpy = "JPY"
    case cad = "CAD"
    case aud = "AUD"
    case chf = "CHF"
    case cny = "CNY"
    case sek = "SEK"
    case nzd = "NZD"
    case inr = "INR"
}
