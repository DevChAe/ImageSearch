//
//  ImageTableViewCell.swift
//  ImageSearch
//
//  Created by ChAe on 13/11/2018.
//  Copyright © 2018 ChAe. All rights reserved.
//

import UIKit
import Kingfisher

class ImageTableViewCell: UITableViewCell, CellConfig {
    // placeholder 이미지가 다양한 해상도 지원을 위해 이미지뷰 중앙에 위치하는게 합리적.
    // UIImageView ContentMode를 Center로 설정후 이미지 로드 -> completionHandler 에서 ContentMode를 scaleAspectFill로 전환시 placeholder가 잠시 scaleAspectFill 모드로 보이는 현상이 발생
    // 이미지 placeholder가 Center에 위치하기 위해 별도의 이미지뷰 클래스를 선언
    private class CenterPositionImageView: UIImageView, Placeholder {
        /// How the placeholder should be added to a given image view.
        public func add(to imageView: ImageView) {
            imageView.image = nil
            imageView.addSubview(self)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: imageView, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: imageView, attribute: .centerY, multiplier: 1, constant: 0)
                ])
        }
        
        /// How the placeholder should be removed from a given image view.
        public func remove(from imageView: ImageView) {
            self.removeFromSuperview()
        }
    }
    
    
    @IBOutlet weak var baseImageView: UIImageView!      // 이미지 뷰
    
    // 이미지 비율에 따른 ratio layout constraint 설정을 위한 변수
    private var imageViewRatioLayoutConstraint: NSLayoutConstraint? {
        didSet {
            if let oldLayoutConstraint = oldValue {
                self.baseImageView.removeConstraint(oldLayoutConstraint)
            }
            
            if let layoutConstraint = imageViewRatioLayoutConstraint {
                self.baseImageView.addConstraint(layoutConstraint)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 재사용시 Ratio LayoutConstraint 제거
        self.imageViewRatioLayoutConstraint = nil
    }
    
    // MARK: - Cell Setup Method
    func setup(rowViewModel: RowViewModel) {
        guard let document = rowViewModel as? DocumentInfo else { return }
        
        // Ratio LayoutConstraint 설정
        let aspect = CGFloat(document.width) / CGFloat(document.height)
        let constraint = NSLayoutConstraint(item: self.baseImageView,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: self.baseImageView,
                                            attribute: .height,
                                            multiplier: aspect,
                                            constant: 0)
        constraint.priority = UILayoutPriority(999)
        self.imageViewRatioLayoutConstraint = constraint
        
        let placeholderImageView = CenterPositionImageView(image: #imageLiteral(resourceName: "placeholder"))
        self.baseImageView.kf.setImage(with: URL(string: document.image_url),
                                       placeholder: placeholderImageView,
                                       options: [.transition(.fade(0.5))],
                                       progressBlock: nil,
                                       completionHandler: nil)
    }
}
