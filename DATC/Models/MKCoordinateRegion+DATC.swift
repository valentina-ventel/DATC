//
//  MKCoordinateRegion+DATC.swift
//  DATC
//
//  Created by Valentina Vențel on 05/01/2020.
//  Copyright © 2020 Valentina Vențel. All rights reserved.
//

import MapKit

extension MKCoordinateRegion {
    public func nw() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: center.latitude + span.latitudeDelta / 2 ,
                                      longitude: center.longitude - span.longitudeDelta / 2 )
    }
    
    public func se() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: center.latitude - span.latitudeDelta / 2,
                                      longitude: center.longitude + span.longitudeDelta / 2)
    }
}
