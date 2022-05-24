//
//  ProductRegistrationController.swift
//  OpenMarket
//
//  Created by song on 2022/05/24.
//

import UIKit

class ProductRegistrationController: UINavigationController {
    private lazy var baseView = ProductRegistrationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray
        addNavigationItems()
    }
    
    private func addNavigationItems() {
       title = "상품등록"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: nil, action: #selector(didTappedaddButton))
    }
    
    @objc private func didTappedaddButton() {
        
    }

}
