//
//  HIDKeyboardEvent.swift
//  Eikana β
//
//  Copyright © 2017年 iMasanari. All rights reserved.
//

import Cocoa
import IOKit.hid

class HIDKeyboardEvent: NSObject {
    var keyEvents: KeyEvents {
        get {
            return (NSApplication.shared().delegate as! AppDelegate).keyEvents
        }
    }
    
    let hidManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    
    func watch() {
        let match: NSMutableDictionary = [
            kIOHIDDeviceUsageKey: kHIDUsage_GD_Keyboard,
            kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop
        ]
        
        IOHIDManagerSetDeviceMatching(hidManager, match)
        
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque());
        
        let keyboardCallback: IOHIDValueCallback = {(context, ioreturn, sender, value) in
            let selfPtr = Unmanaged<HIDKeyboardEvent>.fromOpaque(context!).takeUnretainedValue()
            
            selfPtr.callback(ioreturn: ioreturn, sender: sender, value: value)
        }
        
        IOHIDManagerRegisterInputValueCallback(hidManager, keyboardCallback, context)
        IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode!.rawValue)
        IOHIDManagerOpen(hidManager, IOOptionBits(kIOHIDOptionsTypeNone))
    }
    
    private func callback(ioreturn: IOReturn, sender: UnsafeMutableRawPointer?, value: IOHIDValue) {
        if ioreturn != kIOReturnSuccess {
            return
        }
        
        let element = IOHIDValueGetElement(value)
        let scancode = IOHIDElementGetUsage(element)
        
        if (scancode < 4 || 231 < scancode) && !(scancode == 0x03 && IOHIDElementGetUsagePage(element) == 0xff /* fn key */) {
            return
        }
        
        if IOHIDValueGetIntegerValue(value) == 1 {
            self.keyDown(scancode)
        }
        else {
            self.keyUp(scancode)
        }
        
    }
    
    func keyDown(_ keyCode: UInt32) {
        switch (keyCode) {
        case 139: keyEvents.postKeyEvent(102) // 無変換 -> 英数
        case 138: keyEvents.postKeyEvent(104) // 変換 -> かな
        default: break
        }
    }
    
    func keyUp(_ keyCode: UInt32) {
    }
}
