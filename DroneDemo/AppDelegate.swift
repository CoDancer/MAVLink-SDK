//
//  AppDelegate.swift
//  DroneDemo
//
//  Created by CoDancer on 2019/6/25.
//  Copyright © 2019 IOS. All rights reserved.
//

import UIKit
import Dronecode_SDK_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let drone = Drone.init(address: "134.175.130.23", port: 8890)
        drone.startMavlink.subscribe()
        
        drone.action.arm()
            .andThen(drone.action.takeoff())
            .subscribe()
        return true
    }


}

