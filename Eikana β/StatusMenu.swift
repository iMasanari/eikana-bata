//
//  StatusItemController.swift
//  Eikana
//
//  Copyright © 2017年 iMasanari. All rights reserved.
//

import Cocoa

class StatusMenu: NSMenu {
    static var item: NSStatusItem? = nil
    static var menu: NSMenu!
    
    static func setVisibleIcon(_ state: Bool) {
        if #available(OSX 10.12, *) {
            item?.isVisible = state
        }
        else {
            setVisibleIconOfElCapitan(state)
        }
        
        UserDefaults.standard.set(state, forKey: "visibleIcon")
    }
    
    static func setVisibleIconOfElCapitan(_ state: Bool) {
        if state != (item == nil) {
            return
        }
        
        if state {
            createMenu()
        }
        else {
            NSStatusBar.system().removeStatusItem(item!)
            item = nil
        }
    }
    
    static func createMenu() {
        let item = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        
        item.title = "⌘"
        item.highlightMode = true
        item.menu = menu
        
        self.item = item
    }
    
    override func awakeFromNib() {
        StatusMenu.menu = self
        
        if #available(OSX 10.12, *) {
            StatusMenu.createMenu()
        }
        
        StatusMenu.setVisibleIcon(UserDefaults.standard.integer(forKey: "visibleIcon") == 1)
    }
    
    @IBAction func showAbout(_ sender: Any) {
        NSApp.orderFrontStandardAboutPanel(sender)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func showPreference(_ sender: Any) {
        PreferenceWindowController.getInstance().showAndActivate(sender)
    }
}
