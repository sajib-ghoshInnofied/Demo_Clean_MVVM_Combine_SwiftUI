//
//  ProductDetailsSnapshotTests.swift
//  ProductsCleanMVVMSanpshotTests
//
//  Created by Sajib Ghosh on 14/02/24.
//

import XCTest
import FBSnapshotTestCase
import SwiftUI
@testable import ProductsCleanMVVM

final class ProductDetailsSnapshotTests: FBSnapshotTestCase {

    lazy var productDetailsVC : UIHostingController<ProductDetailsView>? = {
        let productDetailsVC = ProductDetailsView.create(with: ProductItemViewModel(id: 1, title: "Title 1", description: "Description", price: 200, image: "https://cdn.dummyjson.com/product-images/100/thumbnail.jpg"))
        return UIHostingController(rootView: productDetailsVC)
    }()
    
    override func setUp() {
        super.setUp()
        //recordMode = true
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = productDetailsVC
        window.makeKeyAndVisible()
        productDetailsVC?.view.frame = UIScreen.main.bounds
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        productDetailsVC = nil
    }
    
    func test_LaunchFor_ProductDetailsView() {
        let expectation = XCTestExpectation(description: "Some description")
        let result = XCTWaiter.wait(for: [expectation], timeout: 2.0) // wait and store the result
        FBSnapshotVerifyView(productDetailsVC?.view ?? UIView())
        XCTAssertEqual(result, .timedOut)
    }

}
