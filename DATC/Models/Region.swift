//
//  Region.swift
//  DATC
//
//  Created by Valentina Vențel on 02/01/2020.
//  Copyright © 2020 Valentina Vențel. All rights reserved.
//

import UIKit

class Region: NSObject {
    var minLatitude: Float
    var maxLatitude: Float
    var minLongitude: Float
    var maxLongitude: Float
    
    init(minLatitude: Float, maxLatitude: Float, minLongitude: Float, maxLongitude: Float) {
        self.minLatitude = minLatitude
        self.maxLatitude = maxLatitude
        self.minLongitude = minLongitude
        self.maxLongitude = maxLongitude
    }
}
