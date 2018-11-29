//
//  KeywordTableViewCell.swift
//  ImageSearch
//
//  Created by ChAe on 13/11/2018.
//  Copyright © 2018 ChAe. All rights reserved.
//

import UIKit

// 키워드 테이블뷰 델리케이트 프로토콜 설정
protocol KeywordTableViewCellDelegate: class {
    func keywordTableViewCell(_ cell: KeywordTableViewCell, removeButtonActionIndex: Int)
}

class KeywordTableViewCell: UITableViewCell {
    @IBOutlet weak var keywordLabel: UILabel!           // 키워드 표시 Label
    
    weak var delegate: KeywordTableViewCellDelegate?    // Delegate
    
    private var index: Int = 0                          // Cell Index
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - UIButton Action Method
    @IBAction func removeButtonAction(_ sender: Any) {
        // 삭제 버튼 이벤트
        self.delegate?.keywordTableViewCell(self, removeButtonActionIndex: self.index)
    }
    
    // MARK: - Cell Setup Method
    func setup(keywordInfo: RecentKeywordInfo, indexPath: IndexPath) {
        self.keywordLabel.text = keywordInfo.keyword
        self.index = indexPath.row
    }
}
