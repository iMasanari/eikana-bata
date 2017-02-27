//
//  AppDelegate.swift
//  Eikana
//
//  Copyright © 2017年 iMasanari. All rights reserved.
//

import Cocoa
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let keyEvents = KeyEvents()
    let statusMenu = StatusMenu()
    let preference = PreferenceWindowController.getInstance()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        keyEvents.start()
        let userDefaults = UserDefaults.standard
        let updater = SUUpdater.shared()!
        
        updater.feedURL = URL(string: "https://imasanari.github.io/eikana-bata/appcast.xml")
        
        if userDefaults.integer(forKey: "checkUpdate") == 1 {
            updater.checkForUpdatesInBackground()
        }
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
