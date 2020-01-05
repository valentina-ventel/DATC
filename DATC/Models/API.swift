//
//  HTTPReport.swift
//  DATC
//
//  Created by Valentina Vențel on 03/01/2020.
//  Copyright © 2020 Valentina Vențel. All rights reserved.
//

import UIKit
import Foundation


class API: NSObject {
    static let rootEndpoint = "http://127.0.0.1"
    static let getAnimalReports = ""
    static let addAnimalReport = "insertReports.php"
    
    class func addAnimalReport(report: AnimalReport) {
        let urlPath = rootEndpoint + "/" + addAnimalReport
        guard let url = URL(string: urlPath) else {
            print("Invalid URL", urlPath)
            return
        }
        let session = URLSession(configuration: .default)
            
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let postString = "item1=\(report.name)&item2=\(report.latitude)&item3=\(report.longitude)"
        print("Adding animal report: \(postString)")
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request ) {data, response, error in
            
            guard let myData = data as Data?, let _:URLResponse = response, error == nil else {
                print("Error while adding animal report: \(error.debugDescription)")
                return
            }
            
            guard let dataString = NSString(data: myData,
                                            encoding: String.Encoding.utf8.rawValue) else { return }
            print(dataString)
        }
        
        task.resume()
    }
}
