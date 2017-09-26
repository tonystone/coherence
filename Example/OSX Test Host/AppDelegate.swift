//
//  AppDelegate.swift
//  OSX Test Host
//
//  Created by Tony Stone on 9/23/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import Cocoa
import TraceLog

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        /// Configure TraceLog to read the environment first.
        TraceLog.configure()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

