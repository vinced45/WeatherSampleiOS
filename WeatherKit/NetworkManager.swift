//
//  Networking.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import Foundation

let network = NetworkManager()

public class NetworkManager: NSObject {
    
    // MARK: Properties
    let queue = DispatchQueue(label: "Networking Queue")
    
    var session: URLSession!
    
    var baseUrl: String = ""
    
    enum RequestMethod: String {
        case post =     "POST"
        case put =      "PUT"
        case get =      "GET"
        case delete =   "DELETE"
        case head =     "HEAD"
    }
    
    enum NetworkingResult {
        case taskCompleted(URLSessionTask)
        case downloadCompleted(URLResponse, Data)
        case downloading(URLSessionDownloadTask, Double, String)
        case error(Error)
    }
    
    //public var downloads: [String : QBDownload]?
    
    typealias NetworkClosure = (_ result: NetworkingResult) -> Void
    internal var networkCallback: NetworkClosure!
    
    func call(_ url: String, method: RequestMethod = .get, headers: [String: String]? = nil, body: Data? = nil, isDownload: Bool = false, callback: @escaping NetworkClosure) {
        queue.async {
            log.debug("")
            
            self.networkCallback = callback
            self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            
            let wholeUrl: String
            if self.baseUrl.isEmpty {
                wholeUrl = url
            } else {
                wholeUrl = "\(self.baseUrl)/\(url)"
            }
            
            let requestUrl = URL(string: wholeUrl)
            
            var request = URLRequest(url: requestUrl!)
            if let callHeaders = headers {
                for (field, value) in callHeaders {
                    request.addValue(value, forHTTPHeaderField: field)
                }
            }
            
            request.httpMethod = method.rawValue
            
            if let httpBody = body {
                request.httpBody = httpBody
            }
            
            let task: URLSessionTask
            
            if isDownload {
                task = self.session.downloadTask(with: request)
                
            } else {
                task = self.session.dataTask(with: request) { data, response, error in
                    if let err = error {
                        self.networkCallback(NetworkingResult.error(err))
                        return
                    }
                    self.networkCallback(NetworkingResult.downloadCompleted(response!, data!))
                }
            }
            
            task.resume()
        }
    }
}

extension NetworkManager: URLSessionDelegate {
    
}

extension NetworkManager: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("download finished by task")
        if let err = error {
            networkCallback(NetworkingResult.error(err))
            return
        }
        networkCallback(NetworkingResult.taskCompleted(task))
    }
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("downloading by task")
    }
}

extension NetworkManager: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        print("file is a \(response.mimeType)")
        completionHandler(URLSession.ResponseDisposition.becomeDownload)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("data task received data")
    }
}

extension NetworkManager: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("download finished")
        do {
            let data = try Data(contentsOf: location)
            networkCallback(NetworkingResult.downloadCompleted(downloadTask.response!, data))
        } catch {
            let err = NSError(domain: "SaveDataError", code: 401, userInfo: nil)
            networkCallback(NetworkingResult.error(err))
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("downloading")
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
        networkCallback(NetworkingResult.downloading(downloadTask, progress, totalSize))
    }
}
