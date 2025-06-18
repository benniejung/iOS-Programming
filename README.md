<div align="center" style="display: flex; align-items: center; gap: 20px;"> 
<h1 style="margin: 0;">PostiFam</h1> <p style="margin: 4px 0 0;">하루 한 장, 가족과 함께하는 일상 공유 플랫폼</p> </div> </div>

## 🎉 서비스 소개

PostiFam은 Post-it과 Family를 합친 이름으로, 가족 간의 일상을 더 정돈되고 따뜻하게 공유할 수 있는 플랫폼입니다.<br>
대부분의 가족은 카카오톡 단톡방을 통해 소통하지만, 시간이 지나면 사진과 일정이 금세 묻히는 불편함이 있습니다.<br>
PostiFam은 하루 한 장의 사진으로 나의 하루를 기록하고, 가족 캘린더로 일정을 함께 확인할 수 있도록 도와줍니다.

## ✨ 주요 기능
1. Firebase Auth와 Firestore를 활용한 로그인/회원가입
<img width="200" alt="image" src="https://github.com/user-attachments/assets/37ec8055-ef32-4820-8b7c-3b2de5a74baf" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/b3dd9f79-2236-431e-87a0-cf8ea85ee29c" />

2. 홈화면 - 가족 초대 기능
<img width="200" alt="image" src="https://github.com/user-attachments/assets/64be7c17-4f69-476b-880d-bb90f18fa576" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/376a07ae-2c92-4b72-a117-7ffd1e4a89c4" />

<img width="200" alt="image" src="https://github.com/user-attachments/assets/9dcf1d59-90c4-473a-bf00-2c7455220749" />

3. Moments 화면 - 하루에 한 번 게시글 작성 & 공유
<img width="200" alt="image" src="https://github.com/user-attachments/assets/ccd0860b-bfee-47b0-8312-c1657515cc40" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/f238d215-f5f5-4c57-86ac-f38ebadb7866" />

4. Events 화면 - 가족별 일정 공유 & 일정 추가/삭제/수정
<img width="200" alt="image" src="https://github.com/user-attachments/assets/0177b21b-3c34-4d6f-84de-e1cdb9d3e800" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/c5d35e8a-6bdf-4e14-9e2b-08edc1209246" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/a3f7049f-7931-4e22-a96e-b269fc9db924" />

</br>

## 📁 프로젝트 폴더 구조

```
FamilyApp/                          
└── Presentation/               
    ├── Auth/                      # 🔐 로그인/회원가입 등 인증 관련 기능
    │   ├── SignUpViewController.swift 
    │   └── LoginViewController.swift 
    │
    ├── Events/                    # 📅 가족 일정(캘린더) 기능
    │   ├── Model/                
    │   │   └── CalendarModel.swift
    │   ├── ViewController/
    │   │   └── EventsViewController.swift 
    │   └── View/
    │       └── CalendarCellView.swift  
    │
    ├── Moments/                   # 🖼️ 하루 기록(사진 게시 기능)
    │   ├── Model/                
    │   │   ├── DbFirebase.swift  
    │   │   ├── DateModel.swift    
    │   │   └── MomentsModel.swift 
    │   ├── ViewController/
    │   │   ├── MomentsViewController.swift     # Moments 메인 리스트 뷰
    │   │   └── MomentPostViewController.swift  # 게시글 작성 뷰
    │   └── View/
    │       └── DateCellView.swift  # 날짜 선택 셀 뷰
    │
    └── Home/                      # 🏠 앱 메인 홈 탭 (가족 목록, 메인 대시보드 등)
        ├── Model/                 
        ├── View/                  
        └── ViewController/
            ├── TabBarController.swift    
            └── HomeViewController.swift 
```
## 📹 시연
📽️ [시연영상 보러가기](https://youtu.be/KX8P0CYO_0Q?si=OmUjdRZ6uZQgR0j_)


</details>
