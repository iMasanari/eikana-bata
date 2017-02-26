//
//  KeyEvents.swift
//  Eikana
//
//  Copyright © 2017年 iMasanari. All rights reserved.
//

import Cocoa

class KeyEvents: NSObject {
    var keyLog: CGKeyCode?
    
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
        let eventMaskList = [
            CGEventType.keyDown,
            CGEventType.keyUp,
            CGEventType.flagsChanged,
            CGEventType.leftMouseDown,
            CGEventType.leftMouseUp,
            CGEventType.rightMouseDown,
            CGEventType.rightMouseUp,
            CGEventType.otherMouseDown,
            CGEventType.otherMouseUp,
            CGEventType.scrollWheel,
            // CGEventType.MouseMovedMask,
        ]
        
        let eventMask = eventMaskList.reduce(0) { (mask, value) -> UInt32 in
            mask | (1 << value.rawValue)
        }
        
        let callback: CGEventTapCallBack = { (proxy, type, event, refcon) in
            if let observer = refcon {
                let mySelf = Unmanaged<KeyEvents>.fromOpaque(observer).takeUnretainedValue()
                return mySelf.eventCallback(proxy: proxy, type: type, event: event)
            }
            return Unmanaged.passUnretained(event)
        }
        
        let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
        
        guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                               place: .headInsertEventTap,
                                               options: .defaultTap,
                                               eventsOfInterest: CGEventMask(eventMask),
                                               callback: callback,
                                               userInfo: observer)
            else {
                print("failed to create event tap")
                exit(1)
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        CFRunLoopRun()
    }
    
    func eventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        
        if type == CGEventType.flagsChanged {
            if keyCode == 55 {
                if isCommandDown(event.flags) {
                    keyLog = keyCode
                }
                else if keyLog == keyCode {
                    postKeyEvent(102)
                }
            }
            else if keyCode == 54 {
                if isCommandDown(event.flags) {
                    keyLog = keyCode
                }
                else if keyLog == keyCode {
                    postKeyEvent(104)
                }
            }
        }
        else {
            keyLog = nil
        }
        
        return Unmanaged.passUnretained(event)
    }
    
    func isCommandDown(_ flags: CGEventFlags) -> Bool {
        return flags.rawValue & CGEventFlags.maskCommand.rawValue != 0
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
