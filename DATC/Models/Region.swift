//
//  Region.swift
//  DATC
//
//  Created by Valentina Vențel on 02/01/2020.
//  Copyright © 2020 Valentina Vențel. All rights reserved.
//

import UIKit
import MapKit

class Region: NSObject {
    var nw: CLLocationCoordinate2D
    var se: CLLocationCoordinate2D
        
    init(nw: CLLocationCoordinate2D, se: CLLocationCoordinate2D) {
        self.nw = nw
        self.se = se
    }
}
