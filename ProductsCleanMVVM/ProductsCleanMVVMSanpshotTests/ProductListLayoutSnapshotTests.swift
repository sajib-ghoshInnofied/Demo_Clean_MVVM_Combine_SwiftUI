//
//  ProductListLayoutSnapshotTests.swift
//  ProductsCleanMVVMSanpshotTests
//
//  Created by Sajib Ghosh on 14/02/24.
//

import XCTest

import XCTest
import FBSnapshotTestCase
import SwiftUI
@testable import ProductsCleanMVVM

final class ProductListLayoutSnapshotTests: FBSnapshotTestCase {

    lazy var productListLayoutVC : UIHostingController<ProductListLayout>? = {
        let productListLayoutVC = ProductListLayout(items: [
            ProductItemViewModel(id: 1, title: "Title 20", description: "Description 20", price: 200, image: "https://cdn.dummyjson.com/product-images/20/thumbnail.jpg"),
            ProductItemViewModel(id: 2, title: "Title 30", description: "Description 30", price: 300, image: "https://cdn.dummyjson.com/product-images/30/thumbnail.jpg")
        ])
        return UIHostingController(rootView: productListLayoutVC)
    }()
    
    override func setUp() {
        super.setUp()
        //recordMode = true
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = productListLayoutVC
        window.makeKeyAndVisible()
        productListLayoutVC?.view.frame = UIScreen.main.bounds
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        productListLayoutVC = nil
    }
    
    func test_LaunchFor_productListLayoutView() {
        FBSnapshotVerifyView(productListLayoutVC?.view ?? UIView())
    }

}
