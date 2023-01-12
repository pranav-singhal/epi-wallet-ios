//
//  NetworkManager.swift
//  epi-wallet-v1
//
//  Created by Pranav Singhal on 08/01/23.
//

//let BASE_API_URL = "http://localhost:1337"
//let BASE_API_URL = "https://c73b-2401-4900-60f2-204a-f447-4c60-8992-ae49.in.ngrok.io"
let BASE_API_URL = "https://epi-api-b.consolelabs.in"
import Foundation

protocol NetworkManagerDelegate {
    func didCreateUserSubscribition(success: Bool)
}

struct NetworkManager {
    var isUserSubscribed: Bool = false;
    var delegate: NetworkManagerDelegate?

    func createUserSubscription (username: String, token: String) {
        if let url = URL( string: "\(BASE_API_URL)/user/subscription") {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let body: [String: Any] = [
                "username": username,
                "subscription": [
                    "type": "ios",
                    "token": token
                ]
            ]

            do {
                let postData = try JSONSerialization.data(withJSONObject: body, options: []);

                request.httpBody = postData;

                let session = URLSession.shared
                
                let task = session.dataTask(with: request) { data, response, error in
                    
                    if let safeError = error {
                        print("error: while sending request to create subscription: \(safeError)")
                    }

                    if let safeRespone = response as? HTTPURLResponse {
                        print("status code: \(safeRespone.statusCode)")
                        if(safeRespone.statusCode == 200 || safeRespone.statusCode == 400) {
                            print("status code inside")
                            DispatchQueue.main.async {
                                self.delegate?.didCreateUserSubscribition(success: true)
                            }
                        }
                    }
                }
                task.resume()
            }
            catch {
                print("Error: while converting body to post data")
            }
        }
    }
}
