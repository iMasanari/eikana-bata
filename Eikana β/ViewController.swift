//
//  ViewController.swift
//  Eikana
//
//  Copyright © 2017年 iMasanari. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var toggleVisibleIconButton: NSButton!
    @IBOutlet weak var toggleLaunchButton: NSButton!
    
    let userDefaults = UserDefaults.standard
    let launcher = LaunchAtStartup()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        toggleVisibleIconButton.state = userDefaults.integer(forKey: "visibleIcon")
        toggleLaunchButton.state = launcher.isStartupItem() ? NSOnState : NSOffState
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func changeVisibleIconButton(_ sender: Any) {
        StatusMenu.setVisibleIcon(toggleVisibleIconButton.state == NSOnState)
    }

    @IBAction func changeLaunchButton(_ sender: Any) {
        launcher.setLaunchAtStartup(toggleLaunchButton.state == NSOnState)
    }
}
