<div align="center">

**:trophy: 2023 HKNU BRIGHT MAKERS EXPO 캡스톤경진대회 우수상 :trophy:**
# Schedule_Snap

**AI 기술을 활용한 자동 일정 등록 앱**

<img src="https://github.com/user-attachments/assets/7b03d122-cd24-4b4b-9091-32c2f8af2f02" alt="ic_launcher_adaptive_fore" width="200"/>

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)

![Spring](https://img.shields.io/badge/spring-%236DB33F.svg?style=for-the-badge&logo=spring&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazonwebservices&logoColor=white)
![Jenkins](https://img.shields.io/badge/jenkins-%232C5263.svg?style=for-the-badge&logo=jenkins&logoColor=white)

![Google Cloud](https://img.shields.io/badge/Google_Cloud-%234285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)
![KakaoTalk](https://img.shields.io/badge/kakao-ffcd00.svg?style=for-the-badge&logo=kakao&logoColor=000000)
![ChatGPT](https://img.shields.io/badge/chatGPT-74aa9c?style=for-the-badge&logo=openai&logoColor=white)
![Naver](https://img.shields.io/badge/CLOVA_OCR-03C75A?style=for-the-badge&logo=Naver&logoColor=white)

![Figma](https://img.shields.io/badge/figma-%23F24E1E.svg?style=for-the-badge&logo=figma&logoColor=white)
![YouTube](https://img.shields.io/badge/YouTube-%23FF0000.svg?style=for-the-badge&logo=YouTube&logoColor=white)

## 소개영상 (YouTube)  
[![Video Label](https://github.com/user-attachments/assets/5b7f6953-e5ad-430c-9955-435eced3c281)](https://www.youtube.com/watch?v=ExNMmo1e0Rw)  
#### **사진을 누르면 이동합니다**

</div>

# 프로젝트 소개
### 개발 기간
2023.01.10 ~ 2023.11.01 (9개월 26일)
### 맴버
- 팀장 / 프론트 / 기획 & 앱 개발 : 박준영
- 팀원 / 백앤드 / 서버 : 김원래
- 팀원 / 백앤드 / 인공지능 API : 박주성
### 개발 배경
 대학 생활은 할 일이 많습니다. 수업, 시험 날짜, 동아리, 경진대회, 동기들과의 약속 등 다양한 일정들을 바쁜 생활 속에서 관리하기 위해 캘린더에 작성을 했습니다. 이러한 일정을 기록하는 행동은 번거롭고 불편했습니다. 그래서, **“자동으로 일정을 관리해 주는 시스템이 있으면 어떨까?”** 라는 생각했습니다. 이러한 개인의 불편함은 다른 사람들도 공통적으로 느낄 수 있다고 판단이 되었고, 이번 캡스톤 디자인에서 이 프로젝트를 기획하였습니다.

**“일정을 쉽게 등록하는 방법이 무엇이 있을까?“** 라는 생각에서 나온 생각이 사진을 일정으로 바꾸자는 아이디어였습니다. 사진을 일정을 바꾸기 위해서 사진을 데이터로 바꾸어야 했고, OCR이라는 기술이 있다는 것을 알게 됐습니다. 이 기능을 이용하면 구현이 가능하다고 판단을 했고, 이 아이디어를 가지고 프로젝트를 시작하게 됐습니다.

 ### 목표
 Schedule_Snap은 텍스트가 포함된 이미지를 사용자가 전달해 주면, 인공지능 모델이 맞춰서 일정을 자동 생성하는 앱입니다. 이를 가능하게 하기 위해서는 OCR 기술을 활용하여 이미지에서 텍스트를 추출하고, 추출된 텍스트를 NLU & NLP 기술을 이용해 자연어 처리하여 일정표 형식에 맞는 정보로 변환해 줍니다. 이렇게 처리된 정보를 클라이언트에게 제공함으로써, 사용자는 어려운 작업 없이 일정표를 자동으로 생성할 수 있습니다.
 
### 개발 도구
- 프론트 : Flutter (Dart Version: >=2.18.6 <3.0.0)
- 백앤드 : Spring Boot / bash / gradle / Java
- 시스템 : EC2, S3, AWS
- 인공지능 API : CHAT GPT / CLOVA OCR
- 디자인 : Figma

# 설계
### 시스템 구성도
![image](https://github.com/user-attachments/assets/906bc3ec-a8a7-47fa-b576-d9e19d2a59dd)
### UI 디자인
![Frame 67](https://github.com/user-attachments/assets/6c35f9f7-21ff-44d3-bff5-861125bba00d)

# 주요 기능
<details>
<summary>
  일정 등록 (기본)
</summary>
   <img src="https://github.com/user-attachments/assets/ed8cd713-f82f-4c2a-9f37-cb71cca8fd43" width="200" height="400"/>
   <img src="https://github.com/user-attachments/assets/5ed41b4b-5ee6-4368-ad4b-c6e3908c2afb" width="200" height="400"/>
   <img src="https://github.com/user-attachments/assets/7ad881df-2cd7-440e-90ee-15d179d0eaa5" width="200" height="400"/>
   <img src="https://github.com/user-attachments/assets/d912c1fd-c052-4c8b-966c-1177dede4100" width="200" height="400"/>
</details>

<details>
<summary>
  AI 일정 등록 (이미지 / URL / 텍스트)
</summary>
   <img src="https://github.com/user-attachments/assets/170688bd-7e2f-4f94-aa8b-69bef854b5d2" width="200" height="400"/>
   <img src="https://github.com/user-attachments/assets/992c581a-7931-4114-be7e-2625f3706f9e" width="200" height="400"/>
   <img src="https://github.com/user-attachments/assets/12dbbae7-66c1-4cbe-84cd-fb12ac72e269" width="200" height="400"/>
   <img src="https://github.com/user-attachments/assets/a15a8930-0b90-4f9f-932a-f7a8db2b2ba1" width="200" height="400"/>
</details>

<details>
<summary>
  거리 측정 (출발지-목적지 설정)
</summary>
<img src="https://github.com/user-attachments/assets/f29995ae-8ee9-440e-be15-bb55bebaf0c0" width="500" height="300"/>
<img src="https://github.com/user-attachments/assets/bd034181-ed55-42b8-bfca-8c9f0e9a591f" width="150" height="300"/>
<img src="https://github.com/user-attachments/assets/279d6334-bd97-45d6-aff4-c4230bd63bf9" width="150" height="300"/>

사용자가 출발지와 목적지를 <a href="https://postcode.map.daum.net/guide" target="_blank">카카오 우편번호 API</a>를 활용해서 가져오면 </br>
해당 데이터를 기반으로 **URL Scheme**을 통해 타사 지도로 연결해줍니다.

```dart
Map_Button(String text, String URL, String icon) {
...
 child: OutlinedButton(
  style: OutlinedButton.styleFrom(side: BorderSide(width: 1, color: Colors.white)),
   onPressed: (_startlocation.text.isNotEmpty && _endlocation.text.isNotEmpty)
    ? () async {
     await launchUrl(Uri.parse(URL), mode: LaunchMode.externalApplication);
     // 구글 : "https://www.google.com/maps/dir/?api=1&origin=${_startlocation.text}&destination=${_endlocation.text}&travelmode=transit"
     // 네이버 : "nmap://route/public?slat=${start_lat}&slng=${start_lng}&sname=${_startlocation.text}&dlat=${end_lat}&dlng=${end_lng}&dname=${_endlocation.text}&appname={your_appname}"
     // 카카오 : "kakaomap://route?sp=${start_lat},${start_lng}&ep=${end_lat},${end_lng}&by=PUBLICTRANSIT"
  }
...
```
</details>

<details>
<summary>
  일정 시작시 행동
</summary>
<img src="https://github.com/user-attachments/assets/b11628b0-b3e4-47ad-9c47-4dd00753c568" width="500" height="300"/>
<img src="https://github.com/user-attachments/assets/ca5b3710-67c5-48ce-b611-3944fffcc99a" width="300" height="300"/>

<a href="https://pub.dev/packages/device_apps" target="_blank">설치된 앱을 확인</a> 하는 패키지를 활용해서 일정이 시작될 때, 지정된 앱을 실행시키거나, 사이트를 열 수 있습니다. </br>
**해당 패키지는 중단되었기에, <a href="https://pub.dev/packages/installed_apps" target="_blank">다른 패키지</a>를 사용해야합니다.
</details>





