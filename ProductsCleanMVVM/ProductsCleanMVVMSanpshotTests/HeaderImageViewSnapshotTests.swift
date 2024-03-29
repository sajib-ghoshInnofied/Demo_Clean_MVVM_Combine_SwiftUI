//
//  HeaderImageViewSnapshotTests.swift
//  ProductsCleanMVVMSanpshotTests
//
//  Created by Sajib Ghosh on 14/02/24.
//

import XCTest
import FBSnapshotTestCase
import SwiftUI
@testable import ProductsCleanMVVM

final class HeaderImageViewSnapshotTests: FBSnapshotTestCase {

    lazy var headerImageVC : UIHostingController<HeaderImageView>? = {
        let headerImageVC = HeaderImageView(urlString: "https://cdn.dummyjson.com/product-images/50/thumbnail.jpg")
        return UIHostingController(rootView: headerImageVC)
    }()
    
    override func setUp() {
        super.setUp()
        //recordMode = true
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = headerImageVC
        window.makeKeyAndVisible()
        headerImageVC?.view.frame = UIScreen.main.bounds
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        headerImageVC = nil
    }
    
    func test_LaunchFor_HeaderImageView() {
        let expectation = XCTestExpectation(description: "Some description")
        let result = XCTWaiter.wait(for: [expectation], timeout: 3.0) // wait and store the result
        FBSnapshotVerifyView(headerImageVC?.view ?? UIView())
        XCTAssertEqual(result, .timedOut)
    }

}
