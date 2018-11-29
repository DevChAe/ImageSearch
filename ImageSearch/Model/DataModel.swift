//
//  DataModel.swift
//  ImageSearch
//
//  Created by ChAe on 12/11/2018.
//  Copyright © 2018 ChAe. All rights reserved.
//

import UIKit

// TableViewCell 프로토콜
protocol CellConfig {
    func setup(rowViewModel: RowViewModel)
}

// TableViewCell 데이터 표현 뷰모델
protocol RowViewModel { }

// 설명 데이터 모델
struct DescriptionInfo: RowViewModel {
    var keyword: String?
    var desc: String
    
    init(keyword: String, desc: String) {
        self.keyword = keyword
        self.desc = desc
    }
    
    init(desc: String) {
        self.desc = desc
    }
}

// 이미지 도큐먼트 데이터 모델
struct DocumentInfo: RowViewModel, Decodable {
    var collection: String
    var datetime: Date
    var display_sitename: String
    var doc_url: String
    var height: Int
    var image_url: String
    var thumbnail_url: String
    var width: Int
    
    private enum CodingKeys: String, CodingKey {
        case collection, datetime, display_sitename, doc_url, height, image_url, thumbnail_url, width
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.collection = try values.decode(String.self, forKey: .collection)
        
        let dateString = try values.decode(String.self, forKey: .datetime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let datetime = dateFormatter.date(from: dateString) {
            self.datetime = datetime
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.datetime], debugDescription: "시간 데이터 포맷이 맞지 않습니다."))
        }
        
        self.display_sitename = try values.decode(String.self, forKey: .display_sitename)
        self.doc_url = try values.decode(String.self, forKey: .doc_url)
        self.height = try values.decode(Int.self, forKey: .height)
        self.image_url = try values.decode(String.self, forKey: .image_url)
        self.thumbnail_url = try values.decode(String.self, forKey: .thumbnail_url)
        self.width = try values.decode(Int.self, forKey: .width)
    }
}

// 검색 결과 메타 정보 모델
struct metaInfo: Decodable {
    var is_end: Bool
    var pageable_count: Int
    var total_count: Int
}

// 이미지 검색 결과 정보 모델
struct ImageSearchInfo: Decodable {
    var documents: [DocumentInfo]
    var meta: metaInfo
}

// 최근 검색어 데이터 모델
struct RecentKeywordInfo: Codable {
    var keyword: String
    var date: Date
    
    init(keyword: String, date: Date) {
        self.keyword = keyword
        self.date = date
    }
    
    private enum CodingKeys: String, CodingKey {
        case keyword, date
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.keyword = try values.decode(String.self, forKey: .keyword)
        
        let dateString = try values.decode(String.self, forKey: .date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let datetime = dateFormatter.date(from: dateString) {
            self.date = datetime
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.date], debugDescription: "시간 데이터 포맷이 맞지 않습니다."))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.keyword, forKey: .keyword)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.string(from: self.date)
        
        try container.encode(dateString, forKey: .date)
    }
}
