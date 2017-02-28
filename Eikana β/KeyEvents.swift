//
//  KeyEvents.swift
//  Eikana
//
//  Copyright © 2017年 iMasanari. All rights reserved.
//

import Cocoa
import IOKit.hid

class KeyEvents: NSObject {
    var modifierLog: UInt32?
    let hidManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    
    func start() {
        let checkOptionPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let options: CFDictionary = [checkOptionPrompt: true] as NSDictionary
        
        if !AXIsProcessTrustedWithOptions(options) {
            Timer.scheduledTimer(timeInterval: 1.0,
                                 target: self,
                                 selector: #selector(KeyEvents.watchAXIsProcess(_:)),
                                 userInfo: nil,
                                 repeats: true)
        }
        else {
            self.watch()
        }
    }
    
    func watchAXIsProcess(_ timer: Timer) {
        if !AXIsProcessTrusted() {
            return
        }
        
        timer.invalidate()
        self.watch()
    }
    
    func watch() {
        
        // mouse event (use NSEvent)
        
        let mask: NSEventMask = [
            .leftMouseDown,
            .leftMouseUp,
            .rightMouseDown,
            .rightMouseUp,
            .otherMouseDown,
            .otherMouseUp,
            .scrollWheel
        ]
        
        NSEvent.addGlobalMonitorForEvents(matching: mask) {(event: NSEvent) -> Void in
            self.modifierLog = nil
        }
        
        NSEvent.addLocalMonitorForEvents(matching: mask) {(event: NSEvent) -> NSEvent? in
            self.modifierLog = nil
            return event
        }
        
        
        // key event (use HID)
        
        let match = [kIOHIDDeviceUsageKey: kHIDUsage_GD_Keyboard, kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop] as NSMutableDictionary
        
        IOHIDManagerSetDeviceMatching(hidManager, match)
        
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque());
        
        let keyboardCallback: IOHIDValueCallback = {(context, ioreturn, sender, value) in
            if ioreturn != kIOReturnSuccess {
                return
            }
            
            let element = IOHIDValueGetElement(value)
            let scancode = IOHIDElementGetUsage(element)
            
            if (scancode < 4 || 231 < scancode) && !(scancode == 0x03 && IOHIDElementGetUsagePage(element) == 0xff /* fn key */) {
                return
            }
            
            let selfPtr = Unmanaged<KeyEvents>.fromOpaque(context!).takeUnretainedValue()
            
            if IOHIDValueGetIntegerValue(value) == 1 {
                selfPtr.keyDown(scancode)
            }
            else {
                selfPtr.keyUp(scancode)
            }
        }
        
        IOHIDManagerRegisterInputValueCallback(hidManager, keyboardCallback, context)
        IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode!.rawValue)
        IOHIDManagerOpen(hidManager, IOOptionBits(kIOHIDOptionsTypeNone))
    }
    
    func keyDown(_ keyCode: UInt32) {
        if keyCode == UInt32(kHIDUsage_KeyboardLeftGUI) || keyCode == UInt32(kHIDUsage_KeyboardRightGUI) {
            self.modifierLog = keyCode
        }
        else {
            self.modifierLog = nil
        }
    }
    
    func keyUp(_ keyCode: UInt32) {
        if self.modifierLog == keyCode {
            postKeyEvent(keyCode == UInt32(kHIDUsage_KeyboardLeftGUI) ? 102 : 104)
        }
        
        self.modifierLog = nil
    }
    
    func postKeyEvent(_ keyCode: CGKeyCode) {
        let loc = CGEventTapLocation.cghidEventTap
        let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)!
        let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)!
        
        keyDownEvent.flags = CGEventFlags()
        keyUpEvent.flags = CGEventFlags()
        
        keyDownEvent.post(tap: loc)
        keyUpEvent.post(tap: loc)
    }
}
