//
//  HTTPReport.swift
//  DATC
//
//  Created by Valentina Vențel on 03/01/2020.
//  Copyright © 2020 Valentina Vențel. All rights reserved.
//

import UIKit
import Foundation


class HTTPReport: NSObject {
    func insertReport(report: Report) {
        let urlPath = "http://127.0.0.1/insertReports.php"
        
        guard let url = URL(string: urlPath) else {
            print("Invalid URL", urlPath)
            return
        }
        let session = URLSession(configuration: .default)
            
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let postString = "item1=\(report.descriptionReport)&item2=\(report.latitude)&item3=\(report.longitude)"
        print("Add: \(postString)")
        request.httpBody = postString.data(using: String.Encoding.utf8)

        
        let task = session.dataTask(with: request ) {data, response, error in
            
                guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                    print("error")
                    return
                }
                
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("--------insert----------")
                print(dataString)
                print("------------------------")
        }
        
        
        task.resume()
        
    }
}
