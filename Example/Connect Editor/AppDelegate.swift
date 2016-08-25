//
//  AppDelegate.swift
//  Connect Editor
//
//  Created by Tony Stone on 8/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Cocoa
import Connect
import TraceLog

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var rootViewController: MGConnectEditorRootViewController!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        logInfo { "Application Loadded" }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

