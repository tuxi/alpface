//
//  LocationItem.swift
//  Alpface
//
//  Created by swae on 2018/9/22.
//  Copyright © 2018 alpface. All rights reserved.
//

import UIKit

@objc(AlpLocationItem)
open class LocationItem: NSObject {
    /// 经度
    open var longitude: Double?
    /// 纬度
    open var latitude: Double?
    /// 地点名称
    open var name: String?
    /// 地址
    open var address: String?
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(address, forKey: "address")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        longitude = aDecoder.decodeDouble(forKey: "longitude")
        latitude = aDecoder.decodeDouble(forKey: "latitude")
        name = aDecoder.decodeObject(forKey: "name") as? String
        address = aDecoder.decodeObject(forKey: "address") as? String
    }
    
    convenience init(dict: [String : Any]) {
        self.init()
        self.longitude = dict["longitude"] as? Double
        self.latitude = dict["latitude"] as? Double
        self.name = dict["name"] as? String
        self.address = dict["address"] as? String
    }
}
