//
//  ResultViewController.swift
//  ImageSearch
//
//  Created by ChAe on 13/11/2018.
//  Copyright © 2018 ChAe. All rights reserved.
//

import UIKit

// 결과 페이지 ViewController (키보드 감지 ViewController 상속)
class ResultViewController: KeyboardObserveViewController {
    @IBOutlet weak var tableView: UITableView!              // 결과 테이블뷰
    @IBOutlet weak var indicator: UIActivityIndicatorView!  // 로딩 인디케이터
    
    private var rowViewModels: [RowViewModel] = [RowViewModel]()    // 테이블뷰 셀 표현 뷰모델 정보
    private var lastImageSearchRequestInfo: ImageSearchRequestInfo? // 마지막 이미지 요청 정보 기록
    private var isExistMore: Bool = false                           // 결과에 따른 추가 Page 존재 유무
    private var isShowKeyboard: Bool = false                        // 키보드 Show/Hide 여부
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = self.tableView.bounds.width
        
        self.setTableViewInset(keyboardHeight: 0)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Kyeboard Show/Hide Methods
    override func keyboardWillShow(keyboardAtts: KeyboardObserveViewController.KeyboardAttributes) {
        UIView.animate(withDuration: keyboardAtts.duration, delay: 0, options: keyboardAtts.curve, animations: {
                            self.setTableViewInset(keyboardHeight: keyboardAtts.height)
                        }, completion: nil)
        self.isShowKeyboard = true
    }
    
    override func keyboardWillHide(keyboardAtts: KeyboardObserveViewController.KeyboardAttributes) {
        UIView.animate(withDuration: keyboardAtts.duration, delay: 0, options: keyboardAtts.curve, animations: {
            self.setTableViewInset(keyboardHeight: 0)
        }, completion: nil)
        
        self.isShowKeyboard = false
    }
    
    // 테이블뷰 스크롤 Inset, 컨텐츠 Inset 설정 (iPhone X, XR, XS, XS Max, iPad Pro 3rd 하단 영역 계산 포함)
    private func setTableViewInset(keyboardHeight: CGFloat) {
        var bottomSafeArea: CGFloat
        
        if #available(iOS 11.0, *) {
            bottomSafeArea = view.safeAreaInsets.bottom
        } else {
            bottomSafeArea = bottomLayoutGuide.length
        }
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight - (keyboardHeight > 0 ? bottomSafeArea : 0), right: 0)
        self.tableView.scrollIndicatorInsets = insets
        self.tableView.contentInset = insets
    }
    
    // MARK: - Search Methods
    // 이미지 검색 요청
    func requestImageSearch(keyword: String, page: Int = 1) {
        let imageSearchRequestInfo = ImageSearchRequestInfo(keyword: keyword, page: page)
        let isRequst = NetworkManager.shared.requestKakaoImageSearchAPI(imageSearchRequestInfo, success: { (imageSearchInfo) in
            self.lastImageSearchRequestInfo = imageSearchRequestInfo
            self.isExistMore = !imageSearchInfo.meta.is_end
            
            self.rowViewModels.removeAll()
            print("total count: \(imageSearchInfo.meta.total_count)")
            if imageSearchInfo.meta.total_count > 0 && imageSearchInfo.documents.count > 0 {
                self.rowViewModels.append(contentsOf: imageSearchInfo.documents)
            } else {
                self.rowViewModels.append(DescriptionInfo(keyword: imageSearchRequestInfo.keyword, desc: "에 해당하는 이미지가 존재하지 않습니다."))
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if self.rowViewModels.count > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
                
                self.hideIndicator()
            }
        }) { (error) in
            print(error.localizedDescription)
            
            self.rowViewModels.removeAll()
            self.rowViewModels.append(DescriptionInfo(desc: "데이터 통신에 실패하였습니다."))
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.hideIndicator()
            }
        }
        
        if isRequst == true {
            self.showIndicator()
        }
    }
    
    // MARK: - Indicator Methods
    private func showIndicator() {
        self.indicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func hideIndicator() {
        self.indicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // MARK: - TableView Clear Method
    // 테이블뷰 초기화 (SearchBar 텍스트가 비어 있을경우 호출)
    func tableViewClear() {
        self.rowViewModels.removeAll()
        self.tableView.reloadData()
    }
}

extension ResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 이미지 검색 정보가 존재하고, 추가 Page가 있고, 마지막 셀을 본다면..
        if let lastImageSearchRequestInfo = self.lastImageSearchRequestInfo, self.isExistMore == true && indexPath.row == self.rowViewModels.count - 1 {
            // 키워드는 같고 다음페이지를 요청
            let imageSearchRequestInfo = ImageSearchRequestInfo(keyword: lastImageSearchRequestInfo.keyword, page: lastImageSearchRequestInfo.page + 1)
            let _ = NetworkManager.shared.requestKakaoImageSearchAPI(imageSearchRequestInfo, success: { (imageSearchInfo) in
                self.lastImageSearchRequestInfo = imageSearchRequestInfo
                self.isExistMore = !imageSearchInfo.meta.is_end
                
                if imageSearchInfo.meta.total_count > 0 && imageSearchInfo.documents.count > 0 {
                    self.rowViewModels.append(contentsOf: imageSearchInfo.documents)
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
            }) { (error) in
                // 첫 페이지 요청시 실패에 대한 안내는 테이블뷰의 설명 문구 표시로 했지만,
                // 더보기 실패시 이전 표시 이미지 결과를 설명 문구로 표시로 대체할수 없기에 별도의 처리는 하지 않음
                // 추후 개선이 필요하면 Toast나 추가 Interaction 없이 사라지는 형태로 표현
                print(error.localizedDescription)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 키보드가 열려 있는 상태
        if self.isShowKeyboard == true {
            // ResultViewController는 SearchViewController 내 Container 구조이므로 직접 SearchBar 접근이 안됨 (다음 방법중 선택)
            // 1. Delegate 구현
            // 2. Notification Observer 등록 후 Post 호출
            // 3. SearchViewController 객체를 weak 변수 (순환참조 문제 해소)로 연결하여 직접 호출
            
            // 키보드를 내릴수 있도록 Notification 통지
            NotificationCenter.default.post(name: NSNotification.Name("searchBarResignFirstResponder"), object: nil)
        }
    }
}

extension ResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowViewModel = rowViewModels[indexPath.row]
        
        let identifier: String
        switch rowViewModel {
        case is DocumentInfo:
            identifier = "imageCell"
        default:
            identifier = "descCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if let cell = cell as? CellConfig {
            cell.setup(rowViewModel: rowViewModel)
        }
        
        return cell
    }
}
