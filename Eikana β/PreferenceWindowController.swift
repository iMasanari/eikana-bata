//
//  PreferenceWindowController.swift
//  Eikana
//
//  Copyright © 2017年 iMasanari. All rights reserved.
//

import Cocoa

class PreferenceWindowController: NSWindowController, NSWindowDelegate {
    static private var instance: PreferenceWindowController?
    
    static func getInstance() -> PreferenceWindowController {
        if (instance == nil) {
            instance = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "Preference")
                as? PreferenceWindowController
            
            instance!.window?.title = Bundle.main.infoDictionary?["CFBundleName"] as! String
        }
        
        return instance!
    }
    
    func showAndActivate(_ sender: Any) {
        self.showWindow(sender)
        self.window?.makeKeyAndOrderFront(sender)
        NSApp.activate(ignoringOtherApps: true)
    }
}
