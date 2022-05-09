//
//  MarvelComicAppTests.swift
//  MarvelComicAppTests
//
//  Created by Vishal Sonawane on 02/05/22.
//

import XCTest
@testable import MarvelComicApp

class MarvelComicAppTests: XCTestCase {
    func testfetchMarvelCharaters() {
        let expectation = XCTestExpectation(description: "Fetch character list from API")
        MarvelCharacterAPIService().fetchMarvelCharaters(params: ["limit":"30","offset":"0","apikey":Keys.API_PUBLIC_KEY]
                                                         , completion: { result in
            switch result {
            case .success(_):
                XCTAssert(true)
            case .failure(_):
                XCTFail("Failed to fetch charcters from API")
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 20.0)
    }
}
