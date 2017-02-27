//
//  AppDelegate.swift
//  Eikana
//
//  Copyright © 2017年 iMasanari. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let keyEvents = KeyEvents()
    let statusMenu = StatusMenu()
    let preference = PreferenceWindowController.getInstance()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        keyEvents.start()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        preference.showAndActivate(sender)
        
        return false
    }
    
    func stopKeyEvent() {
        
    }
}
