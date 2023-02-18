//
//  ExportSettingBottomSheetView+UITableView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import UIKit

extension ExportSettingBottmSheetView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exportSettings.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = exportSettingsTableView.dequeueReusableCell(withIdentifier: ExportSettingDetailTableViewCell.identifier,
                                                                     for: indexPath) as? ExportSettingDetailTableViewCell else {
            return UITableViewCell()
        }
        
        let exportSetting = exportSettings.value[indexPath.row]
        cell.titleLabel.text = exportSetting.title
        cell.subtitleLabel.text = exportSetting.subtitle
        
        return cell
    }
}

extension ExportSettingBottmSheetView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedExportSetting.accept((exportSettings.value[indexPath.row], type.value))
    }
}
