//
//  ViewController.swift
//  Eikana
//
//  Copyright © 2017年 iMasanari. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var toggleVisibleIconButton: NSButton!
    @IBOutlet weak var toggleAutoLaunchButton: NSButton!
    @IBOutlet weak var toggleCheckUpdateButton: NSButton!
    
    let userDefaults = UserDefaults.standard
    let launcher = LaunchAtStartup()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        toggleVisibleIconButton.state = Settings.get("visibleIcon", defaultValue: 1)
        toggleAutoLaunchButton.state = launcher.isStartupItem() ? NSOnState : NSOffState
        toggleCheckUpdateButton.state = Settings.get("checkUpdate", defaultValue: 1)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func changeVisibleIconButton(_ sender: Any) {
        StatusMenu.setVisibleIcon(toggleVisibleIconButton.state == NSOnState)
    }

    @IBAction func changeAutoLaunchButton(_ sender: Any) {
        launcher.setLaunchAtStartup(toggleAutoLaunchButton.state == NSOnState)
    }
    
    @IBAction func changeCheckUpdateButton(_ sender: Any) {
        Settings.set("checkUpdate", value: toggleCheckUpdateButton.state)
    }
}
