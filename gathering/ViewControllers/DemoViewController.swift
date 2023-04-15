//
//  DemoViewController.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-20.
//

import UIKit

class DemoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return view
        
    }()
    
    // The currently selected index path
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.frame = CGRect(x: 0, y: 0, width: view.width, height: 100)
        
        // Set up the collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register the cell
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.lightGray
        
        // Check if this cell is selected
        if indexPath == selectedIndexPath {
            // Add the color bar to the bottom of the cell
            let colorBar = UIView(frame: CGRect(x: 0, y: cell.bounds.height - 5, width: cell.bounds.width, height: 5))
            colorBar.backgroundColor = UIColor.blue
            colorBar.tag = 100 // Use a tag to find the color bar later
            cell.addSubview(colorBar)
        } else {
            // Remove the color bar from the cell (if it exists)
            cell.viewWithTag(100)?.removeFromSuperview()
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Deselect the old cell (if it exists)
        if let selected = selectedIndexPath {
            selectedIndexPath = nil
            collectionView.reloadItems(at: [selected])
        }
        
        // Select the new cell
        selectedIndexPath = indexPath
        collectionView.reloadItems(at: [indexPath])
        
        // Scroll to the selected cell (if necessary)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Find the cell that should have the color bar
        let center = CGPoint(x: scrollView.contentOffset.x + scrollView.bounds.width / 2, y: scrollView.bounds.height / 2)
        if let indexPath = collectionView.indexPathForItem(at: center) {
            // Update the selected index path
            selectedIndexPath = indexPath
            
            // Reload the cells to update the color bars
            collectionView.reloadData()
        }
    }
}


#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct DEMO: PreviewProvider {
    
    static var previews: some View {
        // view controller using programmatic UI
        DemoViewController().toPreview()
    }
}
#endif

