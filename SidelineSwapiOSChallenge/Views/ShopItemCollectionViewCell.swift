//
//  ShopItemCollectionViewCell.swift
//  SidelineSwapiOSChallenge
//
//  Created by Adam Halper on 9/27/20.
//  Copyright © 2020 Adam Halper. All rights reserved.
//

import UIKit
import Kingfisher

class ShopItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var sellerName: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    override func awakeFromNib() {
      super.awakeFromNib()
      activityIndicator.hidesWhenStopped = true
    }

    func setCell(item: ShopItem?) {
        if let item = item {
            self.itemTitle.text = item.itemName
            self.sellerName.text = item.sellerName
            self.price.text = formatPrice(price: item.price)
            self.setImage(images: item.images)
            
            self.sellerName.alpha = 1
            self.price.alpha = 1
            self.itemTitle.alpha = 1
            activityIndicator.stopAnimating()
        } else {
            self.sellerName.alpha = 0
            self.price.alpha = 0
            self.itemTitle.alpha = 0
            activityIndicator.startAnimating()
        }
    }
    
    func setImage(images: [ImageItem]?) {
        self.imageView.contentMode = .scaleAspectFill
        if let images = images,
            let imageUrlStr = images.first?.smallUrl,
            let url = URL(string: imageUrlStr) {
            DispatchQueue.main.async {
                self.imageView.kf.setImage(with: url)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setCell(item: nil)
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }
    
    func formatPrice(price: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let formattedPrice = formatter.string(from: price as NSNumber) {
            return formattedPrice
        } else {
            return "$\(price)"
        }
    }
}
