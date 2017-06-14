//
//  KeyEvents.swift
//  Eikana β
//
//  Copyright © 2017年 iMasanari. All rights reserved.
//

import Cocoa
import IOKit.hid

class KeyEvents: NSObject {
    var modifierLog: CGKeyCode? = nil
    
    let cgKeyboardEvent = CGKeyboardEvent()
    let hidKeyboardEvent = HIDKeyboardEvent()
    
    func start() {
        let checkOptionPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let options: CFDictionary = [checkOptionPrompt: true] as NSDictionary
        
        if !AXIsProcessTrustedWithOptions(options) {
            Timer.scheduledTimer(
                timeInterval: 1.0,
                target: self,
                selector: #selector(KeyEvents.watchAXIsProcess(_:)),
                userInfo: nil,
                repeats: true
            )
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
    
    private func watch() {
        watchMouseEvent()
        
        cgKeyboardEvent.watch()
        hidKeyboardEvent.watch()
    }
    
    private func watchMouseEvent() {
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
    
    func postMediaEvent(_ key: Int32) {
        let loc = CGEventTapLocation.cghidEventTap
        
        createMediaEvent(key, down: true).post(tap: loc)
        createMediaEvent(key, down: false).post(tap: loc)
    }
}
