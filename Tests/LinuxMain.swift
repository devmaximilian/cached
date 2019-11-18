import XCTest

import CachedTests

var tests = [XCTestCaseEntry]()
tests += CachedTests.allTests()
XCTMain(tests)
