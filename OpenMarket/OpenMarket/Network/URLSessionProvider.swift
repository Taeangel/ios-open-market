//
//  URLSessionProvider.swift
//  OpenMarket
//
//  Created by marlang, Taeangel on 2022/05/12.
//

import UIKit

struct URLSessionProvider<T: Decodable> {
    private let session: URLSessionProtocol
    
    init (session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func fetchData(
        from url: Endpoint,
        completionHandler: @escaping (Result<T, NetworkError>) -> Void) {
            guard let url = url.url else {
                completionHandler(.failure(.urlError))
                return
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            
            request(with: urlRequest, completionHandler: completionHandler)
        }
    
    private func request(
        with request: URLRequest,
        completionHandler: @escaping (Result<T, NetworkError>) -> Void
    ) {
        let task = session.dataTask(with: request) { data, urlResponse, error in
            
            guard error == nil else {
                completionHandler(.failure(.clientError))
                return
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completionHandler(.failure(.statusCodeError))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.dataError))
                return
            }
            
            guard let resultData = T.parse(data: data) else {
                completionHandler(.failure(.decodeError))
                return
            }
            
            completionHandler(.success(resultData))
        }
        task.resume()
    }
    
    func post(
        params: ProductRegistration,
        images: [Images],
        completionHandler: @escaping (Result<T, NetworkError>
        ) -> Void) {
        
        guard let url = URL(string: "https://market-training.yagom-academy.kr/api/products") else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        
        urlRequest.addValue("cd706a3e-66db-11ec-9626-796401f2341a", forHTTPHeaderField: "identifier")
        urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpBody = createBody(params: params, images: images, boundary: boundary)
        let task = session.dataTask(with: urlRequest) { data, urlResponse, error in
            
            guard error == nil else {
                completionHandler(.failure(.clientError))
                return
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completionHandler(.failure(.statusCodeError))
                return
            }
            
            //데이터 부분은 선택이다 데이터를 서버에 전송한뒤 보낸 데이터를 화면에 보여줄지, 서버에서 데이터를 가지고와서 리로드 시켜서 보여주던지
            guard let data = data else {
                completionHandler(.failure(.dataError))
                return
            }
            
            guard let asd = Product.parse(data: data) else {
                return
            }
            
            guard let resultData = T.parse(data: data) else {
                completionHandler(.failure(.decodeError))
                return
            }
            
            completionHandler(.success(resultData))
        }
        task.resume()
    }
    
    func createBody(params: ProductRegistration, images: [Images], boundary: String) -> Data? {
        var body = Data()
        let newline = "\r\n"
        let boundaryPrefix = "--\(boundary)\r\n"
        let boundarySuffix = "\r\n--\(boundary)--\r\n"
        
        Json.encoder.keyEncodingStrategy = .convertToSnakeCase
        
        guard let product = try? Json.encoder.encode(params) else {
            return nil
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"params\"\r\n\r\n")
        body.append(product)
        body.appendString(newline)

        for image in images {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"images\"; filename=\"\(image.fileName).jpeg\"\r\n")
            body.appendString("Content-Type: image/\(image.type)\r\n\r\n")
            body.append(image.data)
            body.appendString("\r\n")
        }

        
        body.appendString(boundarySuffix)
        return body
    }
}

extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

struct ProductRegistration: Codable {
    let name: String
    let price: Int
    let discountedPrice: Int
    let bargainPrice: Int
    let currency: String
    let secret: String
    let descriptions: String
    let stock: Int
}

//struct Product: Decodable {
//    let id: Int?
//    let vendorId: Int?
//    let name: String?
//    let thumbnail: String?
//    let currency: String?
//    let price: Int?
//    let bargainPrice: Int?
//    let discountedPrice: Int?
//    let stock: Int?
//    let createdAt: String?
//    let issuedAt: String?
//}

struct Images {
    let fileName: String
    let type: String
    let data: Data
}
