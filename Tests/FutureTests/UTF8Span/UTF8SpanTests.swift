@testable
import Future

import XCTest


func bitEqual(
  _ span1: UTF8Span,
  _ span2: UTF8Span
) -> Bool {
  span1.unsafeBaseAddress == span2.unsafeBaseAddress && 
  span1._countAndFlags == span2._countAndFlags
}

class UTF8SpanTests: XCTestCase {
  // TODO: basic operations tests

  func testFoo() {
    let str = "abcdefg"
    let span = str.utf8Span
    print(span[0])
  }

  func testInitForwarding() throws {
    // TODO: test we get same bits from various init pathways
    // include null-terminated ones (stripping the isNULL bit of course)
  }

  func testNullTermination() throws {
    func runTest(_ input: String) throws {
      let utf8 = input.utf8
      let nullIdx = utf8.firstIndex(of: 0) ?? utf8.endIndex
      let prefixCount = utf8.distance(
        from: utf8.startIndex, to: nullIdx)

      try Array(utf8).withUnsafeBytes {
        let nullContent = try UTF8Span(
          validatingUnsafeRaw: $0, owner: $0)
        let nullTerminated = try UTF8Span(
          validatingUnsafeRawCString: $0.baseAddress!, owner: $0)

        XCTAssertFalse(nullContent.isNullTerminatedCString)
        XCTAssertTrue(nullTerminated.isNullTerminatedCString)
        XCTAssertEqual(nullContent.count, utf8.count)
        XCTAssertEqual(nullTerminated.count, prefixCount)
      }
    }
    try runTest("abcdefg\0")
    try runTest("abc\0defg\0")
    try runTest("a🧟‍♀️bc\0defg\0")
    try runTest("a🧟‍♀️bc\0\u{301}defg")
    try runTest("abc\0\u{301}defg\0")
  }

  func testContentViews() throws {
    func runTest(_ input: String) throws {
      // TODO: also try input.utf8Span after compiler bug fixes
      
      let array = Array(input.utf8)
//      let span = try UTF8Span(validating: array.storage)

      // TODO: put the iterator code back in as well

      // For convenience, we use the API defined in
      // UTF8SpanViews.swift

      // Scalars
      do {

        try array.withUnsafeBytes {
          let span = try UTF8Span(validatingUnsafeRaw: $0, owner: array)

          var strIdx = input.unicodeScalars.startIndex
          var spanIdx = span.unicodeScalars.startIndex
          while strIdx != input.unicodeScalars.endIndex {
            XCTAssertEqual(
              input.utf8.distance(from: input.startIndex, to: strIdx),
              spanIdx.position)
            XCTAssertEqual(input.unicodeScalars[strIdx], span.unicodeScalars[spanIdx])
            input.unicodeScalars.formIndex(after: &strIdx)
            span.unicodeScalars.formIndex(after: &spanIdx)
          }
          XCTAssertEqual(spanIdx, span.unicodeScalars.endIndex)

          strIdx = input.unicodeScalars.endIndex
          spanIdx = span.unicodeScalars.endIndex
          while strIdx != input.startIndex {
            XCTAssertEqual(
              input.utf8.distance(from: input.startIndex, to: strIdx),
              spanIdx.position)
            input.unicodeScalars.formIndex(before: &strIdx)
            span.unicodeScalars.formIndex(before: &spanIdx)
            XCTAssertEqual(input.unicodeScalars[strIdx], span.unicodeScalars[spanIdx])
          }
        }
      }

      // Characters
      do {

//        var strIdx = input.startIndex
//        var spanIdx = span.characters.startIndex
//        while strIdx != input.endIndex {
//          XCTAssertEqual(
//            input.utf8.distance(from: input.startIndex, to: strIdx),
//            spanIdx.position)
//          XCTAssertEqual(input[strIdx], span.characters[spanIdx])
//          input.formIndex(after: &strIdx)
//          span.characters.formIndex(after: &spanIdx)
//        }
//        XCTAssertEqual(spanIdx, span.characters.endIndex)

//        strIdx = input.endIndex
//        spanIdx = span.characters.endIndex
//        while strIdx != input.startIndex {
//          XCTAssertEqual(
//            input.utf8.distance(from: input.startIndex, to: strIdx),
//            spanIdx.position)
//          input.formIndex(before: &strIdx)
//          span.characters.formIndex(before: &spanIdx)
//          XCTAssertEqual(input[strIdx], span.characters[spanIdx])
//        }
      }

    }

    try runTest("abc")
//    try runTest("abcdefghiljkmnop")
//    try runTest("abcde\0fghiljkmnop")
//    try runTest("a🧟‍♀️bc\0\u{301}defg")
//    try runTest("a🧟‍♀️bce\u{301}defg")
//    try runTest("a🧟‍♀️bce\u{301}defg\r\n 🇺🇸")

  }
}
