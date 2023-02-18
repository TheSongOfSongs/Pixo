//
//  ExportSettingView+UITableView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/18.
//

import UIKit

extension ExportSettingView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSetting.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExportSettingTableViewCell.identifier) as? ExportSettingTableViewCell else {
            return UITableViewCell()
        }
        
        let setting = selectedSetting[indexPath.row]
        cell.nameLabel.text = ExportSettingType(rawValue: indexPath.row)?.name
        cell.titleLabel.text = setting.title
        switch ExportSettingType(rawValue: indexPath.row) {
        case .format:
            cell.subtitleLabel.text = ""
            cell.updateConstraintsWhenNoSubtitle()
        case .quality:
            cell.subtitleLabel.text = setting.subtitle
            cell.updateConstraintsWhenSubtitleExists()
        default:
            break
        }
        
        return cell
    }
}
