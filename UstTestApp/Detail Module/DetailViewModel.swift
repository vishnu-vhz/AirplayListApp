

import Foundation

class DetailViewModel {
    var ipAddressDetails: DetailModel?
    var onDataUpdate: (() -> Void)?
    
    func fetchIPAddressDetails(completion: @escaping (Result<DetailModel, Error>) -> Void) {
        // Fetch public IP address
        let ipifyURL = URL(string: "https://api.ipify.org?format=json")!
        URLSession.shared.dataTask(with: ipifyURL) { data, response, error in
            guard let data = data else {
                completion(.failure(error ?? NSError(domain: "", code: 0, userInfo: nil)))
                return
            }
            do {
                let ipAddressJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let ipAddress = ipAddressJSON?["ip"] as? String else {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse IP address"])
                }
                // Fetch IP address details
                let ipinfoURL = URL(string: "https://ipinfo.io/\(ipAddress)/geo")!
                URLSession.shared.dataTask(with: ipinfoURL) { data, response, error in
                    guard let data = data else {
                        completion(.failure(error ?? NSError(domain: "", code: 0, userInfo: nil)))
                        return
                    }
                    do {
                        let ipDetailsJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        let country = ipDetailsJSON?["country"] as? String ?? ""
                        let city = ipDetailsJSON?["city"] as? String ?? ""
                        let organization = ipDetailsJSON?["org"] as? String ?? ""
                        let carrier = ipDetailsJSON?["carrier"] as? String ?? ""
                        let ipAddressDetails = DetailModel(ipAddress: ipAddress, country: country, city: city, organization: organization, carrier: carrier)
                        self.ipAddressDetails = ipAddressDetails
                        completion(.success(ipAddressDetails))
                    } catch {
                        completion(.failure(error))
                    }
                }.resume()
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

