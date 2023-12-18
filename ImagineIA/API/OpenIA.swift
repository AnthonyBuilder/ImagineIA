//
//  OpenIA.swift
//  ImagineIA
//
//  Created by Anthony José on 30/03/23.
//

import Foundation
import SwiftUI
import Combine


struct AuthModel: Codable {
    let auth: String
}

protocol ImagesProtocol {
   var urls: [Datum] { get }
   var errorResult: OpenIAError { get } // Created for example purposes
}

class ImagesURL: ImagesProtocol, ObservableObject {
    static let sharedSingleton = ImagesURL()
    
    @Published var urls: [Datum] = [Datum(url: "")]
    @Published var errorResult = OpenIAError(error: ErrorModel(message: "", type: ""))
}

class ApiViewModel {
    
    @ObservedObject private var urls = ImagesURL.sharedSingleton
    
    var api = APIOpenIA()
    var text: String
    var numberImages: Int
    
    init(text: String, numberImages: Int) {
        self.text = text
        self.numberImages = numberImages
        
        self.urls.urls = [Datum(url: "")]
        self.urls.errorResult = OpenIAError(error: ErrorModel(message: "", type: ""))
        
        getData()
    }

    func getData() {
        Task {
           await api.generateImage(image: text, number: numberImages, completion: { result in
                switch result {
                case .success(let success):
                    self.urls.urls = success.data!
                    
                    print("success", success)
                case .failure(let failure):
                    self.urls.errorResult = failure
                    
                    print("failure", failure)
                }
            })
        }
    }
}


class APIOpenIA {
    func authRequest(completion: @escaping (AuthModel) -> ()) async {
        var request = URLRequest(url: URL(string: "https://correios-api-drab.vercel.app/api/hello")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                Task {
                    print(String(decoding: data!, as: UTF8.self))
                    do {
                        let authDecoded = try JSONDecoder().decode(AuthModel.self, from: data!)
                        completion(authDecoded)
                    } catch {
                        print(error)
                    }
                }
            }
        }.resume()
    }

    func generateImage(image prompt: String, number: Int, completion: @escaping (Result<OpenIAModel, OpenIAError>) -> ()) async {
        await authRequest() { auth in
            // request on openIA API with type image generate2
            let body: [String: Any] = ["prompt": prompt, "n": number, "size": "1024x1024"]
            let finalBody = try? JSONSerialization.data(withJSONObject: body)
            
            print("Body generate image API: ", body)
            
            guard let url = URL(string: "https://api.openai.com/v1/images/generations") else {
                return
            }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(auth.auth)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = finalBody
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    do {
                        let error_decoded = try JSONDecoder().decode(OpenIAError.self, from: data!)
                        completion(.failure(error_decoded))
                    } catch {
                        let data_decoded = try! JSONDecoder().decode(OpenIAModel.self, from: data!)
                        completion(.success(data_decoded))
                    }
                }
            }.resume()
        }
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
