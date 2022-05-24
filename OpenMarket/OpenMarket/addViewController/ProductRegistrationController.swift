//
//  ProductRegistrationController.swift
//  OpenMarket
//
//  Created by song on 2022/05/24.
//

import UIKit

class ProductRegistrationController: UIViewController {
    private lazy var baseView = ProductRegistrationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addNavigationItems()
    }
    
    private func addNavigationItems() {
       title = "상품등록"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: nil, action: #selector(didTappedDoneButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: nil, action: #selector(didTappedCancelButton))
    }
    
    @objc private func didTappedDoneButton() {
        
    }
    
    @objc private func didTappedCancelButton() {
        
    }

}
