//
//  LayoutType.swift
//  OpenMarket
//
//  Created by marlang, Taeangel on 2022/05/19.
//

import UIKit

enum LayoutType: Int, CaseIterable {
    case list = 0
    case grid = 1
    
    static var inventory: [String] {
        return Self.allCases.map { $0.description }
    }
    
    func size(width: CGFloat, height: CGFloat) -> CGSize {
           switch self {
               case .list: return CGSize(width: width, height: height / 14)
               case .grid: return CGSize(width: width / 2.2, height: height / 3)
           }
       }
    
    func edgeInset() -> UIEdgeInsets {
           switch self {
               case .list: return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
               case .grid: return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
           }
       }
    
    private var description: String {
        switch self {
        case .list:
            return "List"
        case .grid:
            return "Grid"
        }
    }
    
    var cell: CustomCell.Type {
        switch self {
        case .list:
            return ListCell.self
        case .grid:
            return GridCell.self
        }
    }
}
