<div align="center" style="display: flex; align-items: center; gap: 20px;"> 
<h1 style="margin: 0;">PostiFam</h1> <p style="margin: 4px 0 0;">하루 한 장, 가족과 함께하는 일상 공유 플랫폼</p> </div> </div>

🎉 서비스 소개

PostiFam은 Post-it과 Family를 합친 이름으로, 가족 간의 일상을 더 정돈되고 따뜻하게 공유할 수 있는 플랫폼입니다.
대부분의 가족은 카카오톡 단톡방을 통해 소통하지만, 시간이 지나면 사진과 일정이 금세 묻히는 불편함이 있습니다.
PostiFam은 하루 한 장의 사진으로 나의 하루를 기록하고, 가족 캘린더로 일정을 함께 확인할 수 있도록 도와줍니다.

✨ 주요 기능
1. Firebase Auth와 Firestore를 활용한 로그인/회원가입

2. 홈화면 - 가족 초대 기능

3. Moments 화면 - 하루에 한 번 게시글 작성 & 공유

4. Events 화면 - 가족별 일정 공유 & 일정 추가/삭제/수정

</br>

📁 프로젝트 폴더 구조

```
FamilyApp/                          # 전체 iOS 프로젝트 루트
└── Presentation/                  # 화면(View) 관련 구성의 루트 디렉토리 (Feature 단위로 하위 구분)
    ├── Auth/                      # 🔐 로그인/회원가입 등 인증 관련 기능
    │   ├── SignUpViewController.swift # 회원가입 화면 UI
    │   └── LoginViewController.swift # 로그인 기능을 처리하는 ViewController
    │
    ├── Events/                    # 📅 가족 일정(캘린더) 기능
    │   ├── Model/                 # 일정 데이터 모델 정의
    │   │   └── CalendarModel.swift # 캘린더 날짜 생성 및 Firestore 연동
    │   ├── ViewController/
    │   │   └── EventsViewController.swift # 캘린더 화면 전체를 구성하는 컨트롤러
    │   └── View/
    │       └── CalendarCellView.swift    # 날짜 셀에 대한 커스텀 뷰
    │
    ├── Moments/                   # 🖼️ 하루 기록(사진 게시 기능)
    │   ├── Model/                 # 하루 기록 관련 데이터 모델
    │   │   ├── DbFirebase.swift   # Firestore 업로드 로직 등 DB 관련 유틸
    │   │   ├── DateModel.swift    # 날짜 관련 모델
    │   │   └── MomentsModel.swift # 게시글 모델 (작성자, 내용 등 포함)
    │   ├── ViewController/
    │   │   ├── MomentsViewController.swift     # Moments 메인 리스트 뷰
    │   │   └── MomentPostViewController.swift  # 게시글 작성 뷰
    │   └── View/
    │       └── DateCellView.swift  # 날짜 선택 셀 뷰
    │
    └── Home/                      # 🏠 앱 메인 홈 탭 (가족 목록, 메인 대시보드 등)
        ├── Model/                 # 홈 화면에서 필요한 데이터 정의 (현재 비어있을 수 있음)
        ├── View/                  # 홈 화면에 쓰이는 커스텀 뷰
        └── ViewController/
            ├── TabBarController.swift    # 전체 앱의 TabBar 컨트롤러
            └── HomeViewController.swift  # 메인 홈화면 컨트롤러
```
## 📹 시연
📽️ [시연영상 보러가기](https://youtu.be/KX8P0CYO_0Q?si=OmUjdRZ6uZQgR0j_)


</details>
