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
    func itemsDownloaded(items: NSArray)
}

class ReportModel: NSObject {
    //properties
    
    weak var delegate: ReportModelProtocol!
    
    var data = Data()
    
    let urlPath: String = "http://127.0.0.1/selectReports.php" //this will be changed to the path where service.php lives
    
    
    
    
    func downloadItems() {
        
        guard let url = URL(string: urlPath) else {
            print("Invalid URL", urlPath)
            return
        }
        var request = URLRequest(url: url)
            
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                print("Failed to download data with error \(String(describing: error))")
                return
            } else {
                
                
                self.parseJSON(data!)
            }
            
        }
        
        task.resume()
    }

    
    func parseJSON(_ data:Data) {
        
        var jsonResult = NSArray()
        
        do {
            let strData = String(decoding: data, as: UTF8.self)
            print(strData)
                jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement = NSDictionary()
        let reports = NSMutableArray()
        
        for i in 0 ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let animal = Report()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let description = jsonElement["Description"] as? String,
                let latitude = jsonElement["Latitude"] as? Float,
                let longitude = jsonElement["Longitude"] as? Float
            {
                
                animal.descriptionReport = description
                print("--------------------------------------------------------------")
                animal.latitude = latitude
                print(latitude)
                animal.longitude = longitude
                print(longitude)
            }
            
            reports.add(animal)
            
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.delegate.itemsDownloaded(items: reports)
            
        })
    }
}
