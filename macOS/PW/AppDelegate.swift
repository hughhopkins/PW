//
//  AppDelegate.swift
//  PW
//
//  Created by hugh on 04/03/2016.
//  Copyright © 2016 hugh. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Disable window restoration to prevent className=(null) errors
        NSWindow.allowsAutomaticWindowTabbing = false
        for window in NSApp.windows {
            window.isRestorable = false
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @IBAction func menubarPWHelp(_ sender: Any) {
        if let url = URL(string: "http://pwapp.io/about.html?utm_source=OSX&utm_medium=link&utm_content=menubar-help&utm_campaign=OSX") {
            NSWorkspace.shared.open(url)
        }
    }

    @IBAction func menubarPWSite(_ sender: Any) {
        if let url = URL(string: "http://pwapp.io/?utm_source=OSX&utm_medium=link&utm_content=menubar-site&utm_campaign=OSX") {
            NSWorkspace.shared.open(url)
        }
    }

    @IBAction func menubarGitHub(_ sender: Any) {
        if let url = URL(string: "https://github.com/hughhopkins/PW-OSX?utm_source=OSX&utm_medium=link&utm_content=menubar-site&utm_campaign=OSX") {
            NSWorkspace.shared.open(url)
        }
    }

    @IBAction func menubarTwitter(_ sender: Any) {
        if let url = URL(string: "https://twitter.com/pwappio?utm_source=OSX&utm_medium=link&utm_content=menubar-site&utm_campaign=OSX") {
            NSWorkspace.shared.open(url)
        }
    }
}
