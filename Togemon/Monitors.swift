//
//  Monitors.swift
//  Togemon
//
//  Created by Johnson, Brad on 2022-12-31.
//

import Cocoa


class Monitors {
    private var activeMirror: CGDirectDisplayID
    private var displayDict: Dictionary<CGDirectDisplayID, String>
    
    init() {
        activeMirror = kCGNullDirectDisplay
        displayDict = [:]
        _ = getDisplayDict()
        getDisplayList().forEach({
            if CGDisplayIsInMirrorSet($0) != 0 {
                activeMirror = $0
            }
        })
    }
    
    func getActiveMirror() -> CGDirectDisplayID {
        return activeMirror
    }
    
    func getDisplayDict(refresh: Bool = false) -> [CGDirectDisplayID: String] {
        if refresh {
            displayDict.removeAll()
        }
        
        displayDict.merge(dict: NSScreen.screens.reduce(into: [CGDirectDisplayID: String]()) { $0[$1.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID] = $1.localizedName })
        
        return displayDict
    }
    
    private func getDisplayList() -> Array<CGDirectDisplayID> {
        var displayIDList:Array<CGDirectDisplayID>
        var displayCount:UInt32 = 0
        var activeCount:UInt32 = 0      //used as a parameter, but value is ignored
        
        //get count of active displays (by passing nil to CGGetActiveDisplayList)
        postError(CGGetActiveDisplayList(0, nil, &displayCount))
        
        // allocate space for list of displays
        displayIDList = Array<CGDirectDisplayID>(repeating: kCGNullDirectDisplay, count: Int(displayCount))
        
        // fill the list
        postError(CGGetActiveDisplayList(displayCount, &(displayIDList), &activeCount))
        
        return displayIDList
    }
    
    func toggleMirroring(_ primaryMonitorID: CGDirectDisplayID){
        let displayIDList = getDisplayList()
        
        if displayIDList.count == 1 {
            // either it's hardware mirroring or who cares?
            disableHardwareMirroring(primaryMonitorID)
            return
        }
        
        // determine if mirroring is active (only relevant for software mirroring)
        // hack to convert from boolean_t (aka UInt32) to swift's bool
        let displaysMirrored = CGDisplayIsInMirrorSet(primaryMonitorID) != 0
        
        // set master based on current mirroring state
        // if mirroring, master = null, if not, master = main display
        let master = (true == displaysMirrored) ? kCGNullDirectDisplay : primaryMonitorID
        
        // start the configuration
        var configRef:CGDisplayConfigRef? = nil
        
        postError(CGBeginDisplayConfiguration(&configRef))
        
        for i in 0..<Int(displayIDList.count) {
            let currentDisplay = CGDirectDisplayID(displayIDList[i])
            if primaryMonitorID != currentDisplay {
                CGConfigureDisplayMirrorOfDisplay(configRef, currentDisplay, master)
            }
        }
        activeMirror = master
        
        postError(CGCompleteDisplayConfiguration (configRef,CGConfigureOption.permanently))
    }
    
    private func postError(_ error : CGError){
        if error != CGError.success {
            print(error)
        }
    }
    
    private func disableHardwareMirroring(_ primaryMonitorID: CGDirectDisplayID){
        // designed for hardware mirroring with > 1 display
        
        // start the configuration
        var configRef:CGDisplayConfigRef? = nil
        postError(CGBeginDisplayConfiguration(&configRef))
        
        // kCGNullDirectDisplay parameter disables hardware mirroring
        CGConfigureDisplayMirrorOfDisplay(configRef, primaryMonitorID, kCGNullDirectDisplay)
        
        postError(CGCompleteDisplayConfiguration (configRef,CGConfigureOption.permanently))
        activeMirror = kCGNullDirectDisplay
        _ = getDisplayDict(refresh: true)
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
