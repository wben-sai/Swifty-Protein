//
//  NetworkManager.swift
//  swifty-proteins
//
//  Created by XPI-9 on 5/10/2026.
//

import Foundation
import UIKit

class NetworkManager {
    
    static func makeRequest<T: Codable>(withSession: Bool = true, url: URL, data: T, completion: @escaping (Result<Data, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(data)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if withSession {
            request.setValue(UserDefaults.standard.string(forKey: "@XSId") ?? "", forHTTPHeaderField: "XsessionId")
        }
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.waitsForConnectivity = false
        sessionConfig.timeoutIntervalForRequest = 30
        
        let session = URLSession(configuration: sessionConfig)

        session.dataTask(with: request) { data, response, error in

            if let error = error as? URLError {
                if error.code == .timedOut {
                    let timeoutError = NSError(domain: "Network", code: 123, userInfo: [NSLocalizedDescriptionKey: "Request Timeout, try again"])
                    completion(.failure(timeoutError))
                    return
                }
            }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Network error", code: 1, userInfo: nil)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                for (header, value) in httpResponse.allHeaderFields {
                    if "\(header)" == "XsessionId" {
                        UserDefaults.standard.set("\(value)", forKey: "@XSId")
                    }
                    else if "\(header)" == "X-CSRF-TOKEN" {
                        UserDefaults.standard.set("\(value)", forKey: "@XCTOKEN")
                    }
                }
            }

            completion(.success(data))
        }.resume()
    }
}
