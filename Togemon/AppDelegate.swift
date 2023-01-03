//
//  AppDelegate.swift
//  Togemon
//
//  Created by Johnson, Brad on 2022-12-31.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!
    private var monitors: Monitors!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        monitors = Monitors()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("togemon-menubar"))
            button.action = #selector(self.statusBarButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        setupMenu()
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type ==  NSEvent.EventType.rightMouseUp {
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
        } else {
            if let primaryScreen = getScreenWithMouse() as NSScreen? {
                monitors.toggleMirroring(primaryScreen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID)
            }
        }
    }
    
    func setupMenu() {
        menu = NSMenu(title: "Status Bar Menu")
        menu.delegate = self
        
        var menuItem = NSMenuItem.separator()
        menuItem.tag=100
        
        menu.addItem(menuItem)
        
        menuItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menuItem.tag=100
        
        menu.addItem(menuItem)
    }
    
    func getScreenWithMouse() -> NSScreen? {
      let mouseLocation = NSEvent.mouseLocation
      let screens = NSScreen.screens
      let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })

      return screenWithMouse
    }
    
    @objc func menuNeedsUpdate(_ menu: NSMenu) {
        menu.items.forEach({
            if ($0.tag != 100) {
                menu.removeItem($0)
            }
        })
        
        let activeMirror = monitors.getActiveMirror()
        let displayDict = monitors.getDisplayDict()
        
        var i = 0
        
        displayDict.forEach({
            var menuItem: NSMenuItem
            if activeMirror != kCGNullDirectDisplay && activeMirror != $0.key {
                menuItem = NSMenuItem(title: "\($0.value) is toggled off (mirroring \(displayDict[activeMirror]!))", action: #selector(menuItemClicked(item:)), keyEquivalent: String(i+1))
            } else {
                menuItem = NSMenuItem(title: "\($0.value) is toggled on", action: #selector(menuItemClicked(item:)), keyEquivalent: String(i+1))
            }
            menuItem.identifier = NSUserInterfaceItemIdentifier(String($0.key))
            menu.insertItem(menuItem, at: i)
            i += 1
        })
    }
    
    @objc func menuItemClicked(item: NSMenuItem) {
        monitors.toggleMirroring(CGDirectDisplayID(item.identifier!.rawValue)!)
    }
    
    @objc func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil
    }
}
