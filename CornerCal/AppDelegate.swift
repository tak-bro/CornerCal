//
//  AppDelegate.swift
//  CornerCal
//
//  Created by Emil Kreutzman on 23/09/2017.
//  Copyright © 2017 Emil Kreutzman. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var appController: MainMenuController!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let keys = SettingsKeys()
        
        // Set some defaults values for this app's settings
        trySetDefaultValueFor(key: keys.SHOW_SECONDS_KEY, value: false)
        trySetDefaultValueFor(key: keys.SHOW_DATE_KEY, value: true)
        trySetDefaultValueFor(key: keys.SHOW_DAY_OF_WEEK_KEY, value: true)
        trySetDefaultValueFor(key: keys.USE_HOURS_24_KEY, value: true)
        trySetDefaultValueFor(key: keys.SHOW_AM_PM_KEY, value: true)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        appController.refreshState()

        // The status item stays visible for the app's whole lifetime, so the clock
        // keeps ticking. Re-align it after sleep or a manual clock change, when the
        // running timer may have drifted from the wall clock.
        let workspaceCenter = NSWorkspace.shared.notificationCenter
        workspaceCenter.addObserver(self, selector: #selector(resyncClock), name: NSWorkspace.didWakeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resyncClock), name: .NSSystemClockDidChange, object: nil)
    }

    @objc private func resyncClock() {
        appController.resyncClock()
    }

    private func defaultsContains(key: String) -> Bool {
        return UserDefaults.standard.value(forKey: key) != nil
    }
    
    private func trySetDefaultValueFor(key: String, value: Bool) {
        if (!defaultsContains(key: key)) {
            print(String(format: "setting default \"%@\"", key))
            UserDefaults.standard.set(value, forKey: key)
        }
    }

}

