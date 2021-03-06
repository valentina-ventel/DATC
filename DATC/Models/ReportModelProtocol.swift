//
//  ReportModelProtocol.swift
//  DATC
//
//  Created by Valentina Vențel on 30/12/2019.
//  Copyright © 2019 Valentina Vențel. All rights reserved.
//

import UIKit
import Foundation

protocol ReportModelProtocol: class {
    func itemsDownloaded(items: [AnimalReport])
}

class ReportModel: NSObject {
    //properties
    
    weak var delegate: ReportModelProtocol!
    let urlPath: String = "http://127.0.0.1/selectReports.php" //this will be changed to the path where service.php lives
//    let regionReports: Region?
//
//    init(reginReports: Region) {
//        self.regionReports = reginReports
//    }

    func downloadItems(from region: Region) {
        print("""
            Downloading animal reports in [(\(region.nw.latitude), \(region.nw.longitude))
            : (\(region.se.latitude), \(region.se.longitude))]...
            """)

        guard let url = URL(string: urlPath) else {
            print("Invalid URL", urlPath)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"// Compose a query string

        let postString = "item1=\(region.se.latitude)&item2=\(region.nw.latitude)&item3=\( region.nw.longitude)&item4=\( region.se.longitude)";
        request.httpBody = postString.data(using: String.Encoding.utf8)

        let task = URLSession.shared.downloadTask(with: request)
        {(location, response, error) in

            guard let _:NSURL = location as NSURL?, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }

            let urlContents = try! NSString(contentsOf: location!, encoding: String.Encoding.utf8.rawValue)

            
            print("---------------------------------------")
            print("\n\nHello! I'm: \(urlContents) super!!!!")
            
            let myNSData = urlContents.data(using: String.Encoding.utf8.rawValue)
            self.parseJSON(myNSData!)

        }

        task.resume()
        
    }

    
    func parseJSON(_ data:Data) {
        
        var jsonResult = NSArray()
        
        do {
            let strData = String(decoding: data, as: UTF8.self)
            print("***************************************")
            print(strData)
            print("***************************************")
                jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement = NSDictionary()
        var reports = [AnimalReport]()
        
        for i in 0 ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            var descriptionReport: String
            var latitude: Double
            var longitude: Double
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let description = jsonElement["description"] as? String,
                let latitudeString = jsonElement["latitude"] as? String,
                let lat = Double(latitudeString),
                let longitudeString = jsonElement["longitude"] as? String,
                let lon = Double(longitudeString)
            {
                descriptionReport = description
                latitude = lat
                longitude = lon
                reports.append(AnimalReport(name: descriptionReport,
                                            latitude: latitude,
                                            longitude: longitude))
            }
        }
        
        DispatchQueue.main.async(execute: { () -> Void in

            self.delegate.itemsDownloaded(items: reports)

        })
        
    }
}
