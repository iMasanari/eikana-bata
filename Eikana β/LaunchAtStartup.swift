//
//  LaunchAtStartup.swift
//  Eikana
//
//  Copyright © 2017年 iMasanari. All rights reserved.
//

import Cocoa
import ServiceManagement

func setLaunchAtStartup(_ enabled: Bool) {
    let appBundleIdentifier = "io.github.imasanari.eikana-bata-helper"
    
    if SMLoginItemSetEnabled(appBundleIdentifier as CFString, enabled) {
        if enabled {
            print("Successfully add login item.")
            Settings.set("autoLanch", value: 1)
        } else {
            print("Successfully remove login item.")
            Settings.set("autoLanch", value: 0)
        }
    } else {
        print("Failed to add login item.")
    }
}
