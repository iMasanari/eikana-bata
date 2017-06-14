//
//  CGKeyboardEvent.swift
//  Eikana β
//
//  Copyright © 2017年 iMasanari. All rights reserved.
//

import Cocoa

class CGKeyboardEvent: NSObject {
    var keyEvents: KeyEvents {
        get {
            return (NSApplication.shared().delegate as! AppDelegate).keyEvents
        }
    }
    
    static let modifierMasks: [CGKeyCode: CGEventFlags] = [
        54: CGEventFlags.maskCommand,
        55: CGEventFlags.maskCommand,
        56: CGEventFlags.maskShift,
        60: CGEventFlags.maskShift,
        59: CGEventFlags.maskControl,
        62: CGEventFlags.maskControl,
        58: CGEventFlags.maskAlternate,
        61: CGEventFlags.maskAlternate,
        63: CGEventFlags.maskSecondaryFn,
        57: CGEventFlags.maskAlphaShift
    ]
    
    func watch() {
        let eventMaskList = [
            CGEventType.keyDown.rawValue,
            CGEventType.keyUp.rawValue,
            CGEventType.flagsChanged.rawValue,
            UInt32(NX_SYSDEFINED) // Media key Event
        ]
        
        let eventMask = eventMaskList.reduce(0) {(prev, mask) in prev | (1 << mask) }
        let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
        
        let callback: CGEventTapCallBack = {(proxy, type, event, refcon) in
            if let observer = refcon {
                let selfPtr = Unmanaged<CGKeyboardEvent>.fromOpaque(observer).takeUnretainedValue()
                return selfPtr.eventCallback(proxy: proxy, type: type, event: event)
            }
            
            return Unmanaged.passUnretained(event)
        }
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: observer
            ) else {
                print("failed to create event tap")
                exit(1)
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        CFRunLoopRun()
    }
    
    private func eventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        switch type {
        case CGEventType.flagsChanged:
            let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
            
            if CGKeyboardEvent.modifierMasks[keyCode] == nil {
                return Unmanaged.passUnretained(event)
            }
            return event.flags.rawValue & CGKeyboardEvent.modifierMasks[keyCode]!.rawValue != 0 ?
                modifierKeyDown(event) : modifierKeyUp(event)
            
        case CGEventType.keyDown:
            return keyDown(event)
            
        case CGEventType.keyUp:
            return keyUp(event)
            
        default:
            self.keyEvents.modifierLog = nil
            
            return Unmanaged.passUnretained(event)
        }
    }
    
    func modifierKeyDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        
        #if DEBUG
            print(keyCode)
        #endif
        
        self.keyEvents.modifierLog = keyCode
        
        return Unmanaged.passUnretained(event)
    }
    
    func modifierKeyUp(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        
        if keyEvents.modifierLog == keyCode {
            switch (keyCode) {
            case 55: keyEvents.postKeyEvent(102) // left command -> 英数
            case 54: keyEvents.postKeyEvent(104) // right command -> かな
            case 59: keyEvents.toggleCapsLock() // left controle -> toggle capslock
            case 58: keyEvents.postMediaEvent(NX_KEYTYPE_SOUND_DOWN) //left option -> sound down
            case 61: keyEvents.postMediaEvent(NX_KEYTYPE_SOUND_UP) // right option -> sound up
            default: break
            }
        }
        
        self.keyEvents.modifierLog = nil
        
        return Unmanaged.passUnretained(event)
    }
    
    func keyDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        
        #if DEBUG
            print(keyCode)
        #endif
    
        self.keyEvents.modifierLog = keyCode
        
        return Unmanaged.passUnretained(event)
    }
    
    func keyUp(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        self.keyEvents.modifierLog = nil
        
        return Unmanaged.passUnretained(event)
    }
}
