//
//  NotorTests.swift
//  NotorTests
//
//  Created by Rahan Benabid on 6/6/2024.
//

import XCTest
@testable import Notor

final class NotorTests: XCTestCase {
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

    func testSnippetMatching() throws {
        let snippet = Snippet(trigger: "xname", content: "Rahan benabid")
        XCTAssert(snippet.matches("xname"))
        XCTAssert(snippet.matches(" xname"))
        XCTAssert(snippet.matches("the xname"))
        XCTAssert(!snippet.matches("xnotname"))
        XCTAssert(!snippet.matches("xnam"))
        XCTAssert(!snippet.matches("thexname"))
    }

}
