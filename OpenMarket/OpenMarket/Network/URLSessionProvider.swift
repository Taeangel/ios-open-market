//
//  URLSessionProvider.swift
//  OpenMarket
//
//  Created by marlang, Taeangel on 2022/05/12.
//

import UIKit

struct URLSessionProvider<T: Decodable> {
    private let session: URLSessionProtocol
    private let cache = NSCache<NSURL, UIImage>()
    
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
    
    func postData() {
        guard let requestUrl = Endpoint.detailProduct.url else {
            return
        }
        var request = URLRequest(url: requestUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        
        // 리퀘 메소드
        request.httpMethod = "DELETE"
        
        // 리퀘 헤드
        let boundary = "\(UUID().uuidString)"
        
        request.addValue("cd706a3e-66db-11ec-9626-796401f2341a", forHTTPHeaderField: "identifier")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        
        
        // 리퀘 바디
        let fileName = "testFileName"
        guard let imageData = UIImage(named: "")?.jpegData(compressionQuality: 0.8) else {
            return
        }
        
   // https://ifh.cc/g/bYZW4L.jpg
        
        var data = Data()
        
//        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"params\"\r\n\r\n".data(using: .utf8)!)
        data.append("""
                       {
                       \"name\": \"\",
                       \"amount\": 1000,
                       \"currency\": \"KRW\",
                       \"secret\": \"password\",
                       \"descriptions\": \"desc\"
                       }
                       """.data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(fileName).jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpg\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = data
        
        let task = session.dataTask(with: request) { data, response, error in
            print(String(data: data!, encoding: .utf8)!)
            if let error = error {
                print(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("http error")
                return
            }
            
        }
        task.resume()
    }
}
