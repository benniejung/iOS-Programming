import Foundation
import UIKit
import SnapKit
import Then
import Photos
import FirebaseFirestore

final class MomentsViewController: UIViewController {


    private let titleLabel = UILabel().then {
        $0.text = "Moments"
        $0.font = .boldSystemFont(ofSize: 22)
        $0.textColor = .white
    }
    
    private var dateList: [DateModel] = []
    private let today = Date()

    private let gradientBackgroundView = UIView()
    private let gradientLayer = CAGradientLayer()
    
    private let remainingTimeLabel = UILabel().then {
        $0.font = .monospacedDigitSystemFont(ofSize: 18, weight: .medium)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    private let reminderLabel = UILabel().then {
        $0.text = "매일 사진 한 장씩 올려요"
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .gray
        $0.textAlignment = .center
    }


    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 70)
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        $0.collectionViewLayout = layout
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
    }

    private let momentsTableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
    }

    private let cameraButton = UIButton().then {
        let image = UIImage(named: "camera")
        $0.setImage(image, for: .normal)
        $0.layer.cornerRadius = 28
        $0.layer.masksToBounds = true
    }

    private var moments: [MomentsModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDates()
        setupUI()
        fetchMoments()
        startRemainingTimeTimer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = gradientBackgroundView.bounds
    }
    
    private func startRemainingTimeTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let now = Date()
            let calendar = Calendar.current
            let midnight = calendar.startOfDay(for: now).addingTimeInterval(86400) // 다음날 00:00

            let remaining = Int(midnight.timeIntervalSince(now))

            let hours = remaining / 3600
            let minutes = (remaining % 3600) / 60
            let seconds = remaining % 60

            self.remainingTimeLabel.text = String(format: "%02d : %02d : %02d", hours, minutes, seconds)
        }
    }

    


    private func setupUI() {
        view.addSubview(gradientBackgroundView)
        gradientBackgroundView.addSubview(titleLabel)
        gradientBackgroundView.addSubview(collectionView)
        view.addSubview(momentsTableView)
        view.addSubview(cameraButton)
        view.addSubview(remainingTimeLabel)
        view.addSubview(reminderLabel)

        reminderLabel.snp.makeConstraints {
            $0.top.equalTo(remainingTimeLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        // Gradient View
        gradientBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview() // ← safeAreaLayoutGuide 아님!
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(250) // 또는 적절한 값
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.equalToSuperview().offset(20)
        }


        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        remainingTimeLabel.snp.makeConstraints {
            $0.top.equalTo(gradientBackgroundView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        

        momentsTableView.snp.makeConstraints {
            $0.top.equalTo(reminderLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16) // ✅ 카메라 버튼 기준 ❌
        }

        cameraButton.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.width.height.equalTo(56)
        }

        // CollectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: DateCell.identifier)

        // TableView
        momentsTableView.delegate = self
        momentsTableView.dataSource = self
        momentsTableView.register(MomentTableViewCell.self, forCellReuseIdentifier: MomentTableViewCell.identifier)

        cameraButton.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)

        setupGradient()
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(hex: "#6366F1").cgColor,
            UIColor(hex: "#9333EA").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupDates() {
        let calendar = Calendar.current
        let today = Date()
        dateList = (0..<10).map {
            let date = calendar.date(byAdding: .day, value: $0 - 3, to: today)!
            return DateModel(date: date)
        }
    }

    @objc private func didTapCameraButton() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self.presentImagePicker()
                default:
                    print("❌ 접근 거부됨")
                }
            }
        }
    }

    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true)
    }

    private func fetchMoments() {
        Firestore.firestore().collection("moments")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ 순간 불러오기 실패: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self.moments = documents.compactMap { doc in
                    return MomentsModel.from(dict: doc.data())
                }

                self.collectionView.reloadData()
                self.momentsTableView.reloadData()
            }
    }

    final class MomentTableViewCell: UITableViewCell {
         static let identifier = "MomentTableViewCell"
        private let userLabel = UILabel()

         private let contentLabel = UILabel()
         private let timestampLabel = UILabel()
         private let momentImageView = UIImageView()
        private let roleImageView = UIImageView()


         override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
             super.init(style: style, reuseIdentifier: reuseIdentifier)
             setupUI()
         }

         required init?(coder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }

         private func setupUI() {
             backgroundColor = UIColor.systemGroupedBackground
             contentView.layer.cornerRadius = 12
             contentView.clipsToBounds = true
             contentView.backgroundColor = UIColor(red: 243/255, green: 244/255, blue: 255/255, alpha: 1)

             momentImageView.contentMode = .scaleAspectFill
             momentImageView.clipsToBounds = true
             momentImageView.layer.cornerRadius = 8

             contentLabel.numberOfLines = 0
             contentLabel.font = .systemFont(ofSize: 15, weight: .regular)
             contentLabel.textColor = UIColor(named: "TextPrimary") ?? UIColor.darkGray

             timestampLabel.font = .systemFont(ofSize: 12)
             timestampLabel.textColor = .gray
             
             userLabel.font = .systemFont(ofSize: 14, weight: .semibold)
             userLabel.textColor = .darkGray
             roleImageView.contentMode = .scaleAspectFit
             roleImageView.clipsToBounds = true
             
             contentView.addSubview(roleImageView)
             contentView.addSubview(userLabel)


             contentView.addSubview(momentImageView)
             contentView.addSubview(contentLabel)
             contentView.addSubview(timestampLabel)
             contentView.addSubview(userLabel)
         }

         func configure(with model: MomentsModel) {
             userLabel.text = model.userName
             contentLabel.text = model.content

             let formatter = DateFormatter()
             formatter.dateFormat = "yyyy.MM.dd HH:mm"
             timestampLabel.text = formatter.string(from: model.timestamp)

             // Remove existing constraints to reset layout
             momentImageView.snp.removeConstraints()
             contentLabel.snp.removeConstraints()
             timestampLabel.snp.removeConstraints()

             let imageName: String
               switch model.role.lowercased() {
               case "dad": imageName = "icon_dad"
               case "mom": imageName = "icon_mom"
               case "child": imageName = "icon_child"
               default: imageName = "icon_child"
               }

               roleImageView.image = UIImage(named: imageName)

             if model.imageURL.isEmpty {
                 // No image → only text and timestamp
                 momentImageView.isHidden = true

                 contentLabel.snp.makeConstraints {
                     $0.top.equalToSuperview().offset(16)
                     $0.leading.trailing.equalToSuperview().inset(20)
                 }

                 timestampLabel.snp.makeConstraints {
                     $0.top.equalTo(contentLabel.snp.bottom).offset(8)
                     $0.leading.trailing.equalToSuperview().inset(20)
                     $0.bottom.equalToSuperview().offset(-16)
                 }

             } else {
                 // Image exists
                 momentImageView.isHidden = false
                 roleImageView.snp.makeConstraints {
                     $0.top.equalToSuperview().offset(12)
                     $0.leading.equalToSuperview().offset(20)
                     $0.width.height.equalTo(24)
                 }

                 userLabel.snp.makeConstraints {
                     $0.centerY.equalTo(roleImageView)
                     $0.leading.equalTo(roleImageView.snp.trailing).offset(8)
                 }

                 momentImageView.snp.makeConstraints {
                     $0.top.equalToSuperview().offset(50)
                     $0.leading.trailing.equalToSuperview().inset(20)
                     $0.height.equalTo(180)
                     //$0.top.equalTo(userLabel.snp.bottom).offset(8)
                 }

                 contentLabel.snp.makeConstraints {
                     $0.top.equalTo(momentImageView.snp.bottom).offset(10)
                     $0.leading.trailing.equalToSuperview().inset(20)
                 }

                 timestampLabel.snp.makeConstraints {
                     $0.top.equalTo(contentLabel.snp.bottom).offset(8)
                     $0.leading.trailing.equalToSuperview().inset(20)
                     $0.bottom.equalToSuperview().offset(-16)
                 }


                 // Load image
                 if let url = URL(string: model.imageURL) {
                     URLSession.shared.dataTask(with: url) { data, _, _ in
                         guard let data = data else { return }
                         DispatchQueue.main.async {
                             self.momentImageView.image = UIImage(data: data)
                         }
                     }.resume()
                 }
             }
         }
     }
     
}

extension MomentsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dateList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCell.identifier, for: indexPath) as? DateCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: dateList[indexPath.item], today: today)
        return cell
    }
}

extension MomentsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[.originalImage] as? UIImage else { return }

        let composeVC = MomentPostViewController()
        composeVC.selectedImage = selectedImage
        navigationController?.pushViewController(composeVC, animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension MomentsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return moments.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MomentTableViewCell.identifier, for: indexPath) as? MomentTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: moments[indexPath.section])
        return cell
    }

    // ✅ 셀 간 간격용 Footer 추가
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

}


