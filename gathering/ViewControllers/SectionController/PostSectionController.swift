//
//  PostSectionController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-25.
//

import UIKit
import IGListKit

class PostSectionController: ListSectionController {
    
    var viewModel: HomeCellViewModel!
    
    override init() {
        super.init()
        inset = .init(top: 2, left: 0, bottom: 2, right: 0)
    }
    
    override func didUpdate(to object: Any) {
        viewModel = object as? any HomeCellViewModel
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let vm = viewModel as! PostViewModel
        let cell = collectionContext?.dequeueReusableCell(of: PostCell.self, for: self, at: index) as! PostCell
        cell.bindViewModel(vm)
        return cell
        
    }
    
    override func didSelectItem(at index: Int) {
        let viewModel = viewModel as! PostViewModel
        //        let vc = DemoViewController()
        let vc = EventDetailViewController()
//        vc.viewModel = viewModel
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}
