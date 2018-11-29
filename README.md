# iOS 이미지 검색
### 사용자가 입력한 검색 키워드에 대한 이미지 검색 결과를 화면에 표시
### 조건
- Universal
- Swift
- iOS Deployment Target : 9.0
- [Kakao 이미지 검색 API](https://developers.kakao.com/docs/restapi/search#%EC%9D%B4%EB%AF%B8%EC%A7%80-%EA%B2%80%EC%83%89) 이용. (JSON 사용)
- Network : [Alamofire](https://github.com/Alamofire/Alamofire)
- Image Downloader : [Kingfisher](https://github.com/onevcat/Kingfisher)
- 하나의 화면으로 구성 (Presenting, Push 사용 금지)
- 이미지 검색
  - 검색어 필드 화면 상단 표시
  - 검색 버튼은 없음
  - 1초 이상 검색어를 입력하지 않으면 자동 검색
  - 검색 결과 없거나 오류가 발생시 사용자에게 안내해주어야함
  - 검색 결과 표시 뷰에 대한 제한 없음
  - 이미지 가로는 화면폭과 동일. 세로는 이미지 비율에 맞게 표시
- 최근 검색어 표시
  - 검색어 필드가 초기화 되면 최근 검색어 화면이 보임
  - 키보드 검색 버튼 선택시 검색어 저장 (자동 검색 키워드는 저장하지 않음)
  - 저장 방식은 자유 (샘플 UserDefault)
