//
//  GZEUserTests.swift
//  GoozeTests
//
//  Created by Yussel on 10/28/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import XCTest
import Gloss
@testable import Gooze

class GZEUserTests: XCTestCase {

    var userJSON: JSON!
    var user: GZEUser!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        user = nil

        do {

            let url = Bundle(for: type(of: self)).url(forResource: "CompleteUser", withExtension: "json")!
            let jsonData = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? JSON

            userJSON = json
        } catch {
            print(error)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDecodeUserFromJson() {
        user = GZEUser(json: userJSON)

        // Strings
        XCTAssertTrue((user.email == "user1@mail.com"), "Init user from JSON should return correct value")
        XCTAssertTrue((user.id == "123456"), "Init user from JSON should return correct value")
        XCTAssertTrue((user.username == "user1"), "Init user from JSON should return correct value")
        XCTAssertTrue((user.registerCode == "randomCode"), "Init user from JSON should return correct value")
        XCTAssertTrue((user.invitedBy == "other@mail.com"), "Init user from JSON should return correct value")
        XCTAssertTrue((user.origin == "México"), "Init user from JSON should return correct value")
        XCTAssertTrue((user.phrase == "My phrase"), "Init user from JSON should return correct value")

        // Float
        XCTAssertTrue((user.weight == 2), "Init user from JSON should return correct value")
        XCTAssertTrue((user.height == 1.1), "Init user from JSON should return correct value")

        // Bool
        XCTAssertTrue((user.loggedIn == false), "Init user from JSON should return correct value")

        // Enums
        XCTAssertTrue((user.gender?.rawValue == "male"), "Init user from JSON should return correct value")
        XCTAssertTrue((user.mode?.rawValue == "client"), "Init user from JSON should return correct value")
        XCTAssertTrue((user.status?.rawValue == "unavailable"), "Init user from JSON should return correct value")

        // StringArray
        XCTAssertTrue((user.languages?[0] == "español"), "Init user from JSON should return correct value")
        
        // EnumArray
        XCTAssertTrue((user.interestedIn?[0] == "female"), "Init user from JSON should return correct value")

        // Nested Geolocation
        XCTAssertTrue((user.currentLocation?.lat == 0), "Init user from JSON should return correct value")
        XCTAssertTrue((user.currentLocation?.lng == 2.0), "Init user from JSON should return correct value")

        // Nested Photos
        XCTAssertTrue((user.photos?[0].image == "adsfasdg"), "Init user from JSON should return correct value")
        XCTAssertTrue((user.photos?[0].blocked == false), "Init user from JSON should return correct value")

        // Dates
        XCTAssertTrue((user.birthday == GZEUser.dateFormatter.date(from: "2017-10-28T16:01:34.390Z")), "Init user from JSON should return correct value")
        XCTAssertTrue((user.createdAt == GZEUser.dateFormatter.date(from: "2017-10-28T16:01:34.390Z")), "Init user from JSON should return correct value")
        XCTAssertTrue((user.updatedAt == GZEUser.dateFormatter.date(from: "2017-10-28T16:01:34.390Z")), "Init user from JSON should return correct value")
    }
    
}
