//
//  SettingsViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 2/13/19.
//  Copyright © 2019 AshleyNg. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    enum SettingsGroup: String, CaseIterable {
        case app = "TournyMngr"
        case challonge = "Challonge"
        
        var options: [Settings] {
            switch self {
            case .app:
                return [Settings.attribution, Settings.logout]
            case .challonge:
                return [Settings.termsOfService]
            }
        }
    }

    enum Settings: String {
        case logout = "Logout"
        case attribution = "Attribution"
        case termsOfService = "Terms of Service"
    }
    
    let settingsGroupItems: [SettingsGroup] = [
        SettingsGroup.challonge,
        SettingsGroup.app
    ]

    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsGroupItems[section].options.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsGroupItems.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let group = settingsGroupItems[section]
        switch group {
        case .challonge:
            return group.rawValue
        case .app:
            return group.rawValue
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingItem = settingsGroupItems[indexPath.section].options[indexPath.row]
        let cell = UITableViewCell()
        
        switch settingItem {
        case .logout:
            cell.textLabel?.text = settingItem.rawValue
            cell.imageView?.image = UIImage(named: "logout")
        case .attribution:
            cell.textLabel?.text = settingItem.rawValue
        case .termsOfService:
            cell.textLabel?.text = settingItem.rawValue
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let settingItem = settingsGroupItems[indexPath.section].options[indexPath.row]
        
        switch settingItem {
        case .logout:
            UserDefaults.standard.removeObject(forKey: UserDefaults.CHALLONGE_API_KEY)
            UserDefaults.standard.removeObject(forKey: UserDefaults.CHALLONGE_USERNAME_KEY)
            navigationController?.popToRootViewController(animated: true)
        case .attribution:
            showAttributionAlert()
        case .termsOfService:
            present(WebViewController(urlString: "https://challonge.com/terms_of_service"), animated: true, completion: nil)
        }
    }
    
    private func showAttributionAlert() {
        let alertController = UIAlertController(title: "Attribution", message: "Challonge provides their service under a Creative Commons Sharealike License, and is attributed to Bettercast Limited.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }

}
