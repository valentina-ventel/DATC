//
//  Report.swift
//  DATC
//
//  Created by Valentina Vențel on 31/12/2019.
//  Copyright © 2019 Valentina Vențel. All rights reserved.
//

import UIKit

class AnimalReport: NSObject {
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
