# Pixo
## ⚙️ 개발 환경
- Language: Swift 5
- iOS Deployment Target: iOS 15.0 +
- Xcode: 13.0 compatible
<br/>  

## 👩‍💻 기술
- UIKit
- MVVM 디자인 패턴
- RxSwift 사용

<br/>  

## 📚 프레임워크 및 라이브러리 
- 의존성 관리 : [CocoaPods](https://cocoapods.org/)
- 이미지 저장소 : [FirebaseUI/Storage](https://github.com/firebase/FirebaseUI-iOS)
- 비동기 처리 : [RxSwift](https://github.com/ReactiveX/RxSwift), [RxCocoa](https://github.com/ReactiveX/RxSwift/tree/main/RxCocoa), [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources)
- 이미지 처리 : [Kingfisher](https://github.com/onevcat/Kingfisher), [SVGKit](https://github.com/SVGKit/SVGKit)
- Auto Layout : [SnapKit](https://github.com/SnapKit/SnapKit), [Then](https://github.com/devxoul/Then)


<br/>

## ✅ 실행 방법
1. 프로젝트를 클론합니다
2. 터미널에서 프로젝트 경로로 이동합니다
3. 터미널 창에 **pod install**을 입력하여 필요한 라이브러리를 다운받습니다
4. Pixo 폴더로 이동하여 **GoogleService-Info.plist** 파일을 붙여넣습니다
5. **Pixo.xcworkspace** 파일을 열어 실행합니다.
<br/>

## 📱 기능 및 화면
<p align="center">
<img width="180" alt="image" src="https://user-images.githubusercontent.com/46002818/219941586-e18a7436-de4a-4fe6-9e4f-a855c059960d.PNG">
<img width="180" alt="image" src="https://user-images.githubusercontent.com/46002818/219942185-f833dc5f-ba16-4413-adcb-1711c918505b.PNG">
<img width="180" alt="image" src="https://user-images.githubusercontent.com/46002818/219941594-1b31cced-0cb3-48c4-a61f-e75c2eb5292e.PNG">
</p>  

### PhotoPicker
- 앨범에서 사진을 선택할 수 있습니다.
- 상단의 앨범 이름을 탭하면 앨범 > 사진, 사진 > 앨범 리스트로 바뀝니다.
- 사진을 탭하면 이미지를 합성할 수 있는 화면으로 이동합니다.
- 사지을 탭하였을 때, iCloud에서 다운받아야 하는 경우 pie 형태로 진행상태를 알려줍니다.
- 앱을 실행하는 도중, 앨범에 사진이 추가되거나 삭제되는 등의 업데이트가 생기면 반영됩니다.
<br/>  

<p align="center">
<img width="180" alt="image" src="https://user-images.githubusercontent.com/46002818/219941894-dbe1f080-bbea-4ef3-9335-9f3c304a575d.PNG">
<img width="180" alt="image" src="https://user-images.githubusercontent.com/46002818/219941923-892e9a53-e14c-4ab4-bcd0-b196846a1d14.PNG">
</p>  

### OverlayImage
- 앨범에서 가져온 사진이 화면에 띄어집니다.
- 아래 SVG 이미지를 선택하여 화면 중앙에 위치시킵니다.
- SVG 이미지 리스트는 한 번 데이터를 가져올 때 최대 10개씩 가지고 오며, 스크롤이 끝에 닿기 전에 추가 요청을 합니다.
- SVG 이미지가 화면에 추가되면 오버레이 버튼이 생기고 앨범에 저장할 수 있는 추출 화면으로 넘어갑니다.
- x 버튼을 탭하면 PhotoPicker 화면으로 돌아갑니다.
<br/>  

<p align="center">
<img width="180" alt="image" src="https://user-images.githubusercontent.com/46002818/219942270-5ab802c8-1614-48c0-a59c-78e26db61d44.PNG">
<img width="180" alt="image" src="https://user-images.githubusercontent.com/46002818/219942313-6fbfedeb-8045-4339-8458-e276fc14d4ba.PNG">
<img width="180" alt="image" src="https://user-images.githubusercontent.com/46002818/219942339-fec340df-9b23-4481-8393-ad2ab9156190.PNG">
<img width="180" alt="image" src="https://user-images.githubusercontent.com/46002818/219942356-4f601b5b-3e5f-452a-891d-b43db67b59dd.PNG">
</p>  

### Export
- 합성된 이미지가 화면에 띄어집니다.
- 포맷 버튼을 눌러 추출할 파일 형식을 JPEG, PNG로 선택할 수 있습니다.
- 이미지 품질 버튼을 눌러 화질을 '낮은', '최적', '높은' 세 가지로 선택할 수 있습니다.
  - '낮은'은 원본 이미지의 0.5배 해상도입니다.
  - '최적'은 원본 이미지와 해상도가 같습니다.
  - '높은'은 원본 이미지의 2배 해상도입니다.
- '<' 뒤로 가기 버튼을 누르면 OverlayImage 화면으로 돌아갑니다.
- '닫기' 버튼을 누르면 화면 PhotoPicker 화면으로 돌아갑니다.
<br/>  

<p align="center">
<img width="180" alt="image" src="https://user-images.githubusercontent.com/46002818/219946144-6c41ce31-e2be-4765-8b28-20474537561b.PNG">
<img width="180" alt="image" src="https://user-images.githubusercontent.com/46002818/219946159-ec5d4f3c-13be-4623-ae12-941c6891edad.PNG">
<img width="180" alt="image" src="https://user-images.githubusercontent.com/46002818/219946021-f2ee179b-6e40-4420-ae6b-360982053e8f.PNG">
</p> 

### 앨범 결과물
- PNG로 추출한 이미지와 JPEG로 추출한 이미지의 예시입니다.
<br/>  
<br/>  


## 🛠 개발 주요 사항
### 1. MVVM과 Input/Output 구조
<p align="center">
<img width="700" alt="image" src="https://user-images.githubusercontent.com/46002818/219943451-b6f05fb3-4516-4613-88a0-dd456f7ccb34.png">
</p>  

- 각 화면마다 데이터를 가져오고 처리하는 이벤트가 많습니다. MVC 패턴을 사용하면 View Controller에서 모두 처리하면 코드가 길어지고  View Controller의 역할이 모호해집니다. MVVM 디자인 패턴을 사용하여 Model로부터 획득한 데이터를 View Model에서 알맞게 가공하여 넘겨주는 방식으로 구현하였습니다.
- Input, Ouput 구조를 사용하여 데이터의 흐름을 분리하였습니다. 이를 통해 가독성이 높아졌으며 View Controller는 View Model에 임의로 접근하여 데이터를 변질시킬 수 없어 안정성이 보장됩니다.

### 2. Rx
- 앨범 사진(PHAsset)에서 이미지(UIImage)를 요청하는 작업은 비동기입니다. RxSwift를 사용하여 작업이 완료되는 시점에 이벤트를 방출하여, 해당 이벤트를 구독하고 있는 객체는 다음 작업을 실행합니다. 탈출 클로저를 사용하지 않기 때문에 가독성이 높아지고, 구독하는 이벤트에 관한 코드를 원하는 위치에 구현할 수 있어 편리합니다.
- Stroyboard, xib를 사용하지 않고 코드 베이스로 화면을 구현하였습니다. UIButton과 같은 UIEvent에 대한 처리가 필요한 경우 복잡한 코드를 작성하지 않고 RxCocoa를 사용하여 쉽게 바인딩하였습니다.

### 3. Swift Concurrency
- FirebaseUI/Storage 라이브러리에서 async 함수를 지원하여 completion handler를 사용하지 않고 Swift Concurrency를 도입하였습니다. 비동기로 실행되지만 동기처럼 읽히기 때문에 코드의 실행순서가 쉽게 파악되는 장점이 있습니다.

### 4. SVG 이미지 처리
- Xcode 12부터 Bundle에 추가된 svg 이미지를 UIImage로 사용할 수 있습니다. 저장소의 이미지는 URL을 통해 이미지 데이터를 받아와 UIImage로 변환하는 형태이나 SVG 이미지는 변환되지 않습니다. 따라서 URL을 통해 다운로드받은 Data를 SVGKit을 이용하여 UIImage로 변환하였습니다.
- Storage Reference로부터 async 함수를 이용하여 비동기로 다운로드받을 URL을 획득합니다. 이 때, 시간차가 발생할 수 있다고 생각하여 URLCacheManager를 구현했습니다. key 값은 Storage Reference의 fullPath이며, value는 데이터를 다운로드할 수 있는 URL입니다.
- SVGKit을 사용하여 이미지를 얻는 것보다, Kingfihser 프레임워크를 사용하여 데이터 다운로드 시, svg를 다운할 수 있는 processor를 넣어주는 것이 눈에 띄게 빨라 Kingfisher 프레임워크를 도입했습니다. 하지만 간헐적으로 캐싱된 이미지를 가져오는데 실패하여 ImageCacheManager를 직접 구현하였습니다.
- Storage Reference로부터 URL을 얻고 이미지를 가져오는 작업 모두 IdentifiableImageView에서 실행됩니다. 이미지 처리 관련 로직은 반복되서 사용될 수 있기 때문에 분리하였습니다. 또한 cell 재사용 시 이미지 깜빡임 이슈를 막고자 identifier를 지정하였습니다. 이미지를 비동기로 가져온 뒤, cell이 재사용되어 원하는 이미지 뷰가 맞는지 확인합니다.

### 5. 오버레이 이미지 합성
- 오버레이 이미지 합성을 화면에 보여지는 뷰를 Context를 이용하여 UIImage를 추출하였습니다. 그러나 앨범에 저장되었을 때 원본 이미지와 비교하여 화질이 떨어진 것을 확인하였고, 원본이미지에 SVG 이미지를 그려주는 방식으로 변경하였습니다.
- Context를 이용하여 이미지를 그릴 때, opaque와 scale을 이용하여 이미지 포맷과 화질 옵션을 지원하였습니다.
<br/>   


## 🔥 추가 개발 사항
### 여러 오버레이 이미지 합성
- 오버레이 이미지를 선택하면 이미지 뷰가 생성되고 overlayImageView를 담는 배열에 추가됩니다. 현재는 오버레이 이미지를 선택하면 이전에 추가된 이미지들은 모두 제거되지만, 오버레이 이미지의 크기와 위치를 조정하는 기능을 구현하면 여러 장의 오버레이 이미지를 추가해도 겹치지 않게 화면에서 조정할 수 있습니다. 오버레이 이미지와 크기를 조정하는 기능을 개발 후, overlayImageView에 담아주면 이미지 합성 및 추출하는 코드는 따로 구현할 필요가 없습니다.
