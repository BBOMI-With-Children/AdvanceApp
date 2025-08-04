## AdvanceApp

Kakao Book Search API를 활용해 책을 검색하고, **최근 본 책**과 **담은 책**을 관리할 수 있는 iOS 애플리케이션입니다.

사용 기술:

* **UIKit**
* **RxSwift** & **RxCocoa** (MVVM)
* **CoreData**
* SnapKit, Then, Alamofire, Kingfisher

---

### 주요 기능

1. **책 검색**

   * Kakao API를 이용한 도서 검색
   * 무한 스크롤(Infinite Scroll)로 추가 페이지 로딩
   * RxDataSources를 활용한 검색 결과 TableView 바인딩

2. **헤더 배너**

   * `BannerView`로 프로모션 배너 표시
   * `BannerViewModel`에서 배너 데이터 관리 (현재 1개)

3. **최근 본 책**

   * 검색 결과 클릭 시 CoreData에 저장
   * `RecentBookCell`을 활용한 가로 스크롤 CollectionView
   * 펼치기/접기 토글 기능 제공

4. **담은 책 (MyPage)**

   * `SavedBookManager`로 CoreData CRUD 처리
   * `MyPageViewController`에서 RxSwift 바인딩
   * 전체 삭제 버튼 및 검색 탭으로 이동해 포커스 기능

5. **상세 화면**

   * `BookDetailViewController`에서 도서 정보, 썸네일, 가격 표시
   * Kingfisher로 이미지 로딩
   * 중복 저장 방지 및 알림 처리

---

### 아키텍처 (MVVM + RxSwift)

* **ViewModels**

  * `SearchViewModel`
  * `BannerViewModel`
  * `MyPageViewModel`
* **Reactive Components**

  * `BehaviorRelay`, `Driver`, `Observable`을 사용해 데이터 및 이벤트 흐름 관리

---

### 네트워크

* **BookService** (Alamofire + RxSwift)

  * Kakao 도서 검색 API 호출
  * 페이지당 15개 결과 제공

---

### UI & 레이아웃

* **SnapKit**: 코드 기반 Auto Layout
* **Then**: 초기화 코드 간결화
* **RxDataSources**: TableView 섹션 모델 바인딩
* **UICollectionViewCompositionalLayout**: 배너 및 최근 본 책 가로 스크롤 구현

---

### 데이터 저장

* **CoreData**

  * `BookEntity`로 최근 본 책 및 담은 책 관리
  * `SavedBookManager`에서 CRUD 메서드 제공
* **중복 체크**: 동일 타이틀 + 저자 중복 저장 방지

---

### 프로젝트 구조

```
AdvanceApp/
├─ Model/
│  ├─ Book.swift
│  ├─ BookItem+CoreData.swift
│  └─ BannerViewData.swift
├─ Service/
│  ├─ BookService.swift
│  └─ SavedBookManager.swift
├─ ViewModel/
│  ├─ SearchViewModel.swift
│  ├─ BannerViewModel.swift
│  └─ MyPageViewModel.swift
├─ ViewControllers/
│  ├─ MainTabBarController.swift
│  ├─ SearchViewController.swift
│  ├─ BookDetailViewController.swift
│  └─ MyPageViewController.swift
├─ View/
│  ├─ BannerView.swift
│  └─ Cell/
│     ├─ BookCell.swift
│     └─ RecentBookCell.swift
└─ Resources/
   ├─ Assets.xcassets
   └─ Secrets.plist (API Key)
```

---

![Simulator Screen Recording - iPhone 16 Pro - 2025-08-04 at 17 48 03](https://github.com/user-attachments/assets/4b2bd4a7-45d8-4501-9ecd-9a77e2c8c375)|![Simulator Screen Recording - iPhone 16 Pro - 2025-08-04 at 17 48 45](https://github.com/user-attachments/assets/17612b91-a0db-44b3-adef-ac9734f643e2)
---|---|


검색 페이지 -> 상세 페이지 -> 담은 책 페이지
<img width="979" height="170" alt="스크린샷 2025-08-04 오후 5 28 48" src="https://github.com/user-attachments/assets/a633cab0-5d58-4a74-ba67-6a8a88d0351d" />
