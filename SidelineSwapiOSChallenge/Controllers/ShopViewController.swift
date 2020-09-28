//
//  ShopViewController.swift
//  SidelineSwapiOSChallenge
//
//  Created by Adam Halper on 9/27/20.
//  Copyright © 2020 Adam Halper. All rights reserved.
//

import UIKit

class ShopViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var currentPage = 1
    private var isFetchInProgress = false
    private var lastQuery : String = ""
    private var totalItemCount = 0

    private var currentCount: Int {
      return shopItems.count
    }

    private var shopItems = [ShopItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        searchBar.delegate = self
        initializeHideKeyboard()
        loadDefault()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let cellWidth = (view.frame.width - horizontalSpacing)/2
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        }
    }
    
    private func loadDefault() {
        fetchItems(query: "nike", page: nil)
    }
}

//MARK: - Search Bar Delegate Methods
extension ShopViewController: UISearchBarDelegate {
    
    private func fetchItems(query: String, page: Int?) {
        guard !isFetchInProgress else { return }
        if query != lastQuery {
            currentPage = page ?? 1
        }
        isFetchInProgress = true
        ShopItem.items(matching: query, page: page) { [unowned self] response in
            guard let response = response else { return }
            
            DispatchQueue.main.async {
                self.currentPage += 1
                self.totalItemCount = response.totalItemCount
                self.isFetchInProgress = false

                if query == self.lastQuery {
                    self.shopItems.append(contentsOf: response.items)
                    let indexPathsToReload = self.calculateIndexPathsToReload(from: response.items)
                    self.onFetchCompleted(with: indexPathsToReload)

                } else {
                    self.shopItems = response.items
                    self.lastQuery = query
                    self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                          at: .top,
                    animated: false)
                    self.onFetchCompleted(with: .none)
                }
                /*
                if response.pageNumber > 1 {
                    let indexPathsToReload = self.calculateIndexPathsToReload(from: response.items)
                    self.onFetchCompleted(with: indexPathsToReload)
                } else {
                    self.onFetchCompleted(with: .none)
                }
                */
            }
        }
    }
        
    private func calculateIndexPathsToReload(from newItems: [ShopItem]) -> [IndexPath] {
        let startIndex = shopItems.count - newItems.count
        let endIndex = startIndex + newItems.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    private func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleItems).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }

    private func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            collectionView.isHidden = false
            collectionView.reloadData()
            return
        }

        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        collectionView.reloadItems(at: indexPathsToReload)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.newFetchRequest(_:)), object: searchBar)
        perform(#selector(self.newFetchRequest(_:)), with: searchBar, afterDelay: 0.50)
    }
    
    @objc func newFetchRequest(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespaces) != "" else {
            return
        }
        fetchItems(query: query, page: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text, !query.isEmpty {
            fetchItems(query: query, page: nil)
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
    
}

//MARK: - Collection View Methods
extension ShopViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func isLoadingCell(for indexPath: IndexPath) -> Bool {
        let isLoadingResult = indexPath.row >= currentCount
        return isLoadingResult
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == currentCount - 6 {
            fetchItems(query: lastQuery, page: currentPage)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalItemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "shopItemCollectionViewCell", for: indexPath) as! ShopItemCollectionViewCell
        
        if isLoadingCell(for: indexPath) || shopItems.count <= indexPath.row  {
            return cell
        } else {
            cell.setCell(item: shopItems[indexPath.row])
        }
        return cell
    }

    /* IF HEIGHT AND WIDTH OF CELLS NEED TO BE FIXED:
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 170, height: 260)
    }
    */
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let noOfCellsInRow = 2

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: 260)
    }
}

// MARK: - Keyboard Handling
extension ShopViewController {
    
    
    func initializeHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


