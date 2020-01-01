//
//  Report.swift
//  DATC
//
//  Created by Valentina Vențel on 31/12/2019.
//  Copyright © 2019 Valentina Vențel. All rights reserved.
//

import UIKit

class Report: NSObject {
    var descriptionReport: String?
    var latitude: Float?
    var longitude: Float?
    
    init(descriptionReport: String, latitude: Float, longitude: Float) {
        self.descriptionReport = descriptionReport
        self.latitude = latitude
        self.longitude = longitude
    }
    
    override init() { }
}