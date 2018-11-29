//
//  DescriptionTableViewCell.swift
//  ImageSearch
//
//  Created by ChAe on 13/11/2018.
//  Copyright © 2018 ChAe. All rights reserved.
//

import UIKit
import SwiftyAttributes

class DescriptionTableViewCell: UITableViewCell, CellConfig {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textLabel?.numberOfLines = 0   // 텍스트 라인 설정
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Cell Setup Method
    func setup(rowViewModel: RowViewModel) {
        guard let descInfo = rowViewModel as? DescriptionInfo else { return }
        
        let descAttri = descInfo.desc.withAttributes([
            .textColor(.darkText),
            .font(.systemFont(ofSize: 17.0))
            ])
        
        var finalString = descAttri
        
        // 키워드가 존재하면 키워드 정보를 표기
        if let keyword = descInfo.keyword {
            let apostropheAttri = "'".withAttributes([
                .textColor(.darkText),
                .font(.systemFont(ofSize: 17.0))
                ])
            
            let keywordAttri = "\(keyword)".withAttributes([
                .textColor(.red),
                .font(.systemFont(ofSize: 17.0))
                ])
            
            finalString = apostropheAttri + keywordAttri + apostropheAttri + finalString
        }
        
        self.textLabel?.attributedText = finalString
    }
}
