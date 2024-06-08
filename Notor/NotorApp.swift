//
//  NotorApp.swift
//  Notor
//
//  Created by Rahan Benabid on 6/6/2024.
//

import SwiftUI

@main
struct NotorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    getPermission()
                }
        }
    }
    func getPermission() {
        AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        )
    }
 }
