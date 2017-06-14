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
        #if DEBUG
            print(keyCode)
        #endif
        
        self.modifierLog = keyCode
    }
    
    func keyUp(_ keyCode: UInt32) {
        if let modifierLog = self.modifierLog {
            switch (Int(modifierLog)) {
            case kHIDUsage_KeyboardLeftGUI:
                postKeyEvent(102) // 英数キー
                
            case kHIDUsage_KeyboardRightGUI:
                postKeyEvent(104) // かなキー
                
            case kHIDUsage_KeyboardLeftAlt:
                postSystemEvent(NX_KEYTYPE_SOUND_DOWN)
                
            case kHIDUsage_KeyboardRightAlt:
                postSystemEvent(NX_KEYTYPE_SOUND_UP)
                
            default: break
            }
        }
        
        
        self.modifierLog = nil
    }
    
    private func postKeyEvent(_ keyCode: CGKeyCode) {
        let loc = CGEventTapLocation.cghidEventTap
        let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)!
        let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)!
        
        keyDownEvent.flags = CGEventFlags()
        keyUpEvent.flags = CGEventFlags()
        
        keyDownEvent.post(tap: loc)
        keyUpEvent.post(tap: loc)
    }
    
    private func createMediaEvent(_ key: Int32, down: Bool) -> CGEvent {
        let flags = NSEventModifierFlags(rawValue: down ? 0xa00 : 0xb00)
        let data1 = (Int(key) << 16) | ((down ? 0xa : 0xb) << 8)
        
        let ev = NSEvent.otherEvent(
            with: NSEventType.systemDefined,
            location: NSPoint(x:0.0, y:0.0),
            modifierFlags: flags,
            timestamp: TimeInterval(0),
            windowNumber: 0,
            context: nil,
            // context: 0,
            subtype: 8,
            data1: data1,
            data2: -1
        )
        
        return ev!.cgEvent!
        
    }
    
    private func postSystemEvent(_ key: Int32) {
        let loc = CGEventTapLocation.cghidEventTap
        
        createMediaEvent(key, down: true).post(tap: loc)
        createMediaEvent(key, down: false).post(tap: loc)
    }
}
