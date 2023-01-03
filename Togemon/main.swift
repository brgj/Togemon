//
//  main.swift
//  Togemon
//
//  Created by Johnson, Brad on 2022-12-31.
//

import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
