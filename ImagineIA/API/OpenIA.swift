//
//  OpenIA.swift
//  ImagineIA
//
//  Created by Anthony José on 30/03/23.
//

import Foundation

    class APIOpenIA: ObservableObject {
        
        func generateImage(image prompt: String, number: Int, completion: @escaping (Result<OpenIAModel, OpenIAError>) -> ()) async {
            // request on openIA API with type image generate2
            let body: [String: Any] = ["prompt": prompt, "n": number, "size": "1024x1024"]
            let finalBody = try? JSONSerialization.data(withJSONObject: body)
            
            guard let url = URL(string: "https://api.openai.com/v1/images/generations") else {
                 return
             }
            
            var request = URLRequest(url: url)
            
            request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = finalBody

            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    Task {
                        print(String(decoding: data!, as: UTF8.self))
                        do {
                            let error_decoded = try JSONDecoder().decode(OpenIAError.self, from: data!)
                            completion(.failure(error_decoded))
                        } catch {
                            let data_decoded = try! JSONDecoder().decode(OpenIAModel.self, from: data!)
                            completion(.success(data_decoded))
                        }
                    }
                }
            }.resume()
        }
    }

// MARK: - OpenIAModel
struct OpenIAModel: Codable {
    let created: Int?
    let data: [Datum]?
}

// MARK: - Datum
struct Datum: Codable, Hashable {
    let url: String
}


// MARK: - OpenIAError
struct OpenIAError: Error, Codable {
    let error: ErrorModel
}

// MARK: - Error
struct ErrorModel: Codable {
    let message: String
    let type: String
}


enum NetworkError: Error {
    case transportError(Error)
    case serverError(statusCode: Int)
    case noData
    case decodingError(Error)
    case encodingError(Error)
}
