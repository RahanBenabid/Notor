//
//  ContentView.swift
//  Notor
//
//  Created by Rahan Benabid on 6/6/2024.
//

/**
 the app contains:
 1. Text tracking, globally for now, should add locally too
 2. Snippet Matching
 3. insert the content
    - delete the trigger
    - insert the content
 */

import SwiftUI
import Sauce


//struct Notor {
//    let trigger: String
//    let content: String
//}

struct Snippet {
    let trigger: String
    let content: String
    
    /**
     ## Matches
     - xname
     -  xname
     - the xname
     
     ## Not Matches
     - xnotname
     - xnam
     - thexname
     */
    func matches(_ string: String) -> Bool {
        let hasSuffix = string.hasSuffix(trigger)
        let isBoundary = (string.dropLast(trigger.count).last ?? " ").isWhitespace
        return hasSuffix && isBoundary 
    }
}

extension Snippet {
    static var examples : [Snippet] = [
        Snippet(trigger: "xname", content: "Rahan Benabid"),
        Snippet(trigger: "xmail", content: "rahannadime@gmail.com"),
        Snippet(trigger: "xsnippet", content:"Snippet(trigger: \"<#trigger#>\", content:\"<#content#>\"),"),
    ]
}

extension NSEvent {
    var isDelete: Bool {
        keyCode == 51
    }
}


class NotorModel: ObservableObject {
    
    @Published var text = ""
    @Published var Snippets = Snippet.examples
    
    init() {
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { (event ) in   //this only monitors global key  events, we need to monitor local one for it to work on the app
            self.text = ""
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event ) in
            guard let characters = event.characters else { return }
            print(characters, event.keyCode)
            if event.isDelete && !self.text.isEmpty{
                self.text.removeLast()
            } else if event.keyCode > 100 {
                self.text = ""
            } else {
                self.text += characters
            }
            
            self.matchSnippet()
        }
    }
    
    func matchSnippet() {    //we call this every time our text changes
        if let match = Snippets.first(where: { $0.matches(self.text) }) {
            insertSnippet(match)
        }
    }
        
    
    
    func delete() {
        let eventSource = CGEventSource(stateID: .combinedSessionState)
        
        let keyDownEvent = CGEvent(
            keyboardEventSource: eventSource,
            virtualKey: CGKeyCode(51),
            keyDown: true)
        
        let keyUpEvent = CGEvent(
            keyboardEventSource: eventSource,
            virtualKey: CGKeyCode(51),
            keyDown: false)
        
        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
    }
    func paste() {
        let keyCode = Sauce.shared.keyCode(for: .v)
        let eventSource = CGEventSource(stateID: .combinedSessionState)
        
        let keyDownEvent = CGEvent(
            keyboardEventSource: eventSource,
            virtualKey: keyCode,
            keyDown: true)
        
        keyDownEvent?.flags.insert(.maskCommand)
        
        let keyUpEvent = CGEvent(
            keyboardEventSource: eventSource,
            virtualKey: keyCode,
            keyDown: false)
        
        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
    }

    func insertSnippet (_ snippet: Snippet) {
        print("inserting \(snippet)")
        
        // delete the trigger
        // - KeyDown
        // - KeyUp
        
        for _ in snippet.trigger {
            self.delete ()
            
        }
        
        // insert the content
        // we'll use the NSPasteborad API, to interact with the clipboard
        // 1. save the old clipboard
        let oldClipBoard = NSPasteboard.general.string(forType: .string)
        
        // 2. update the clipboard the content of snippet
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(snippet.content, forType: .string)
        
        // 3. hit command+V
        paste()
        
        // 4. return the clipboard to the old state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {     //kind of a wiggle room since they cannot stop everything they're doing for us, so this is just a safety measure
            if let oldClipBoard = oldClipBoard { // in case it does not exist
                NSPasteboard.general.setString(oldClipBoard, forType: .string)
            }
        }
    }
}



struct ContentView: View {
    @StateObject var model = NotorModel()
    
    var body: some View {
        VStack {
            Text("\(model.text)")
            List(model.Snippets, id: \.trigger) { snippet in
                HStack {
                    Text(snippet.trigger)
                    Text(snippet.content).lineLimit(1)
                }.foregroundColor(snippet.matches(model.text) ? Color.red : Color.primary)
            }
        }
        .padding()
        .frame(width: 300, height: 300)
    }
}

#Preview {
    ContentView()
}
    

