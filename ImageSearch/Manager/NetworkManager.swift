//
//  NetworkManager.swift
//  ImageSearch
//
//  Created by ChAe on 12/11/2018.
//  Copyright © 2018 ChAe. All rights reserved.
//

import UIKit
import Alamofire

// 네트워크 에러 정보
enum NetworkError: LocalizedError {
    case AlreadyRequest
    case NonData
    case NonKakaoApiKey
    
    var localizedDescription: String {
        switch self {
        case .AlreadyRequest:
            return "이미 요청중입니다."
        case .NonData:
            return "데이터가 존재하지 않습니다."
        case .NonKakaoApiKey:
            return "카카오 API 키를 입력하세요."
        }
    }
    
    var errorDescription: String? { return localizedDescription }
}

// 이미지 검색 요청 정보
struct ImageSearchRequestInfo {
    enum SortType: String {
        case accuracy = "accuracy"
        case recency = "recency"
    }
    
    var keyword: String
    var sort: SortType = .accuracy
    var page: Int = 1
    var size: Int = 20
    
    init(keyword: String) {
        self.keyword = keyword
    }
    
    init(keyword: String, page: Int) {
        self.keyword = keyword
        self.page = page
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private let kakaoImageSearchUrl = "https://dapi.kakao.com/v2/search/image"  // 카카오 이미지 검색 API URL
    private let kakaoRestApiKey = ""            // 카카오 API Key
    
    // API 통신 SessionManager 타임아웃 설정
    private var manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 5     // 데이터 수신 간격 5초
        configuration.timeoutIntervalForResource = 10   // 전체 10초
        return SessionManager(configuration: configuration)
    }()
    
    private var lastImageSearchRequestInfo: ImageSearchRequestInfo?     // 마지막에 요청한 이미지검색정보 기록
    private var lastImageSearchDataRequest: DataRequest?                // 마지막에 요청한 세션 정보
    
    private init() { }
    
    // MARK: - Cancel Methods
    // 카카오 이미지 검색 중단
    func cancelKakaoImageSearch() {
        self.lastImageSearchDataRequest?.cancel()
        self.lastImageSearchDataRequest = nil
        self.lastImageSearchRequestInfo = nil
    }
    
    // MARK: - Request Methods
    
    // 카카오 이미지 검색 API 요청
    func requestKakaoImageSearchAPI(_ info: ImageSearchRequestInfo, success: @escaping (ImageSearchInfo) -> (), fail: @escaping (Error) -> ()) -> Bool {
        guard !self.kakaoRestApiKey.isEmpty else {
            fail(NetworkError.NonKakaoApiKey)
            return false
        }
        
        // 마지막 요청 정보 존재 확인
        if let lastInfo = self.lastImageSearchRequestInfo {
            // 현재 동작중인 세션이 확인
            if let dataRequest = self.lastImageSearchDataRequest {
                if info.keyword == lastInfo.keyword, info.page == lastInfo.page {
                    // 현재 동작중인 세션이 있고, 요청 정보가 같은경우 (현재 요청 실패 처리)
                    fail(NetworkError.AlreadyRequest)
                    return false
                } else {
                    // 현재 동작중인 세션을 취소
                    dataRequest.cancel()
                    self.lastImageSearchDataRequest = nil
                    self.lastImageSearchRequestInfo = nil
                }
            } else {
                // 마지막 성공한 정보에 대한 요청시 API 호출을 하지 않는다.
                if info.keyword == lastInfo.keyword, info.page == lastInfo.page {
                    return false
                }
            }
        }
        
        let dataRequest =
            self.manager.request(self.kakaoImageSearchUrl,
                                 method: .get,
                                 parameters: ["query": info.keyword, "sort": info.sort, "page": info.page, "size": info.size],
                                 encoding: URLEncoding.default,
                                 headers: ["Authorization": "KakaoAK \(self.kakaoRestApiKey)"])
                .responseData { (response) in
                    if let error = response.result.error {
                        fail(error)
                        self.lastImageSearchRequestInfo = nil
                    } else {
                        if let data = response.data {
                            do {
                                let imageSearchInfo = try JSONDecoder().decode(ImageSearchInfo.self, from: data)
                                success(imageSearchInfo)
                            } catch {
                                fail(error)
                                self.lastImageSearchRequestInfo = nil
                            }
                        } else {
                            fail(NetworkError.NonData)
                            self.lastImageSearchRequestInfo = nil
                        }
                    }
                    
                    self.lastImageSearchDataRequest = nil
        }
        
        if let url = dataRequest.request?.url?.absoluteString {
            print("[이미지 검색 API 호출]", url)
        }
        
        self.lastImageSearchRequestInfo = info
        self.lastImageSearchDataRequest = dataRequest
        
        return true
    }
}
