//
//  SearchViewController.swift
//  ImageSearch
//
//  Created by ChAe on 12/11/2018.
//  Copyright © 2018 ChAe. All rights reserved.
//

import UIKit

// 검색 ViewController
class SearchViewController: UIViewController {
    @IBOutlet weak var resultContainerView: UIView!                 // 결과 컨테이너 뷰
    @IBOutlet weak var searchBar: UISearchBar!                      // 상단 서치 바
    @IBOutlet weak var tableView: UITableView!                      // 최근 검색어 테이블뷰
    private weak var resultViewController: ResultViewController!    // 결과 컨트롤러 객체 연결을 위한 변수
    
    private var searchWorkItem: DispatchWorkItem?                   // 검색 이벤트
    private var recentKeywords: [RecentKeywordInfo] = [RecentKeywordInfo]() // 최근 검색어 정보들
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.searchBar.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        // SearchBar 키보드 닫힘을 위한 Notification Observer 등록
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(searchBarResignFirstResponder),
                                               name: NSNotification.Name("searchBarResignFirstResponder"),
                                               object: nil)
        
        self.loadRecentKeywords()   // 최근 검색어 로드
    }
    
    deinit {
        // Notification Observer 제거
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name("searchBarResignFirstResponder"),
                                                  object: nil)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "resultViewController" {
            // 결과 ViewController 객체 연결
            self.resultViewController = (segue.destination as! ResultViewController)
        }
    }
    
    // MARK: - Notification Methods
    // 키보드 닫기
    @objc private func searchBarResignFirstResponder() {
        if self.searchBar.isFirstResponder {
            self.searchBar.resignFirstResponder()
        }
    }
    
    // MARK: - UIButton Action Methods
    // 최근 검색어 모두 삭제 버튼 이벤트
    @IBAction func removeAllRecentKeywordsButtonAction(_ sender: Any) {
        self.recentKeywords.removeAll()
        self.tableView.reloadData()
    }
    
    // MARK: - Recent Keyword Methods
    // 최근 검색어 저장 (UserDefault)
    private func saveRecentKeywords() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(self.recentKeywords)
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "RecentKeywords")
        userDefaults.synchronize()
    }
    
    // 최근 검색어 로드 (UserDefault)
    private func loadRecentKeywords() {
        let userDefaults = UserDefaults.standard
        
        if let data = userDefaults.object(forKey: "RecentKeywords") as? Data {
            do {
                let recentKeywords = try JSONDecoder().decode([RecentKeywordInfo].self, from: data)
                self.recentKeywords = recentKeywords
                self.tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }
    
    // 최근 검색어 추가 (키워드가 있는경우 현재 시간으로 업데이트후 정렬 시킴)
    private func insertKeywords(keyword: String) {
        let indexs = self.recentKeywords.enumerated().filter{$0.element.keyword == keyword}.map{$0.offset}
        if let index = indexs.first {
            self.recentKeywords[index].date = Date()
            self.recentKeywords = self.recentKeywords.sorted { $0.date > $1.date }
        } else {
            self.recentKeywords.insert(RecentKeywordInfo(keyword: keyword, date: Date()), at: 0)
        }
        
        self.saveRecentKeywords()
    }
    
    // MARK: - Request Image Search Method
    // 이미지 검색 요청 함수
    private func requestImageSearch(keyword: String) {
        // 결과창 표시
        self.resultContainerView.isHidden = false
        
        // 결과 ViewController에 이미지 검색 요청
        self.resultViewController.requestImageSearch(keyword: keyword)
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recentKeywordInfo = self.recentKeywords[indexPath.row]
        self.insertKeywords(keyword: recentKeywordInfo.keyword)
        self.tableView.reloadData()
        self.requestImageSearch(keyword: recentKeywordInfo.keyword)
        self.searchBar.text = recentKeywordInfo.keyword
        self.searchBar.resignFirstResponder()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBarResignFirstResponder()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentKeywords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "keywordCell", for: indexPath) as! KeywordTableViewCell
        
        let recentKeywordInfo = self.recentKeywords[indexPath.row]
        
        cell.setup(keywordInfo: recentKeywordInfo, indexPath: indexPath)
        cell.delegate = self
        
        return cell
    }
}

extension SearchViewController: KeywordTableViewCellDelegate {
    // 최근 검색어 삭제 이벤트 (Cell Index)
    func keywordTableViewCell(_ cell: KeywordTableViewCell, removeButtonActionIndex: Int) {
        self.recentKeywords.remove(at: removeButtonActionIndex)
        self.tableView.reloadData()
    }
}

extension SearchViewController: UISearchBarDelegate {
    // 검색바 텍스트 변경 이벤트
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 검색바 텍스트 존재유무 체크
        if searchText.isEmpty {
            // 검색바 텍스트가 없는 경우
            
            // 결과창 초기화
            self.resultViewController.tableViewClear()
            // 결과창 숨기기
            self.resultContainerView.isHidden = true
            // 검색 이벤트 제거 (취소)
            self.searchWorkItem?.cancel()
            // 호출중인 API 취소
            NetworkManager.shared.cancelKakaoImageSearch()
        } else {
            // 검색바 텍스트가 존재하면
            // 검색 이벤트 제거 (취소)
            self.searchWorkItem?.cancel()
            // 검색 이벤트 설정
            self.searchWorkItem = DispatchWorkItem {
                // 검색바 텍스트를 백스페이스로 누르고 있으면 연속적으로 제거가 된다.
                // 텍스트가 완전 비어 있지만 현재 textDidChange 이벤트를 수신 받지 못하는 경우가 발생 된다.
                // 1초뒤 실행될 검색 이벤트에서 다시 한번 검색바의 텍스트를 가져와 체크하면 1초의 딜레이가 있지만 원치 않은 키워드 (현재 이벤트가 동작한 마지막 키워드)로 검색되는 현상을 막을수 있다.
                // textDidChange 이벤트의 searchText 사용 대신 self.searchBar.text로 체크한다. (searchText사용시 스냅샷으로 값이 저장됨)
                if let searchText = self.searchBar.text, searchText.isEmpty == false {
                    self.requestImageSearch(keyword: searchText)
                } else {
                    // 결과창 초기화
                    self.resultViewController.tableViewClear()
                    // 결과창 숨기기
                    self.resultContainerView.isHidden = true
                    // 호출중인 API 취소
                    NetworkManager.shared.cancelKakaoImageSearch()
                }
            }
            
            // 1초후 검색 이벤트가 실행되도록 설정
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: self.searchWorkItem!)
            // 결과창 표시
            self.resultContainerView.isHidden = false
        }
    }
    
    // 키보드에 검색 버튼 혹은 엔터를 눌렸을때 이벤트
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 키보드 닫기
        searchBar.resignFirstResponder()
        
        // 검색 이벤트 제거 (취소)
        self.searchWorkItem?.cancel()
        
        // 검색 요청
        if let keyword = searchBar.text, keyword.isEmpty == false {
            requestImageSearch(keyword: keyword)
            
            self.insertKeywords(keyword: keyword)   // 최근 검색 키워드 등록
            self.tableView.reloadData()
        }
    }
}
