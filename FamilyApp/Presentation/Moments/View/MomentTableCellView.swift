//
//  MomentTableCellView.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/17.
//

import Foundation

final class MomentTableViewCell: UITableViewCell {
    static let identifier = "MomentTableViewCell"
    
    private let contentLabel = UILabel()
    private let timestampLabel = UILabel()
    private let momentImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.addSubview(contentLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(momentImageView)

        momentImageView.contentMode = .scaleAspectFill
        momentImageView.clipsToBounds = true
        momentImageView.layer.cornerRadius = 8

        contentLabel.numberOfLines = 0
        contentLabel.font = .systemFont(ofSize: 14)
        
        timestampLabel.font = .systemFont(ofSize: 12)
        timestampLabel.textColor = .gray

        momentImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(180)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(momentImageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        timestampLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with model: MomentsModel) {
        contentLabel.text = model.content
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        timestampLabel.text = formatter.string(from: model.timestamp)

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
