//
//  LoginViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var apiKeyTextField: UITextField!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!

    private let CHALLONGE_USERNAME_KEY = "Challonge_Username_Key"
    private let CHALLONGE_API_KEY = "Challonge_API_Key"

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.isHidden = true
        apiKeyTextField.delegate = self
        if let savedUsername = UserDefaults.standard.string(forKey: CHALLONGE_USERNAME_KEY),
            let savedApiKey = UserDefaults.standard.string(forKey: CHALLONGE_API_KEY) {
            print("Found saved credentials")
            testCredentialsAndLogin(username: savedUsername, apiKey: savedApiKey)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        guard let username = usernameTextField.text,
            let apiKey = apiKeyTextField.text else {
            return
        }
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()

        testCredentialsAndLogin(username: username, apiKey: apiKey) {
            self.loadingIndicator.isHidden = true
            self.loadingIndicator.stopAnimating()
        }
    }

    private func testCredentialsAndLogin(username: String, apiKey: String, completion: (() -> Void)? = nil ) {
        let networking = ChallongeNetworking(username: username, apiKey: apiKey)
        networking.checkCredentials() { [weak self] statusCode in
            completion?()
            guard let `self` = self, let statusCode = statusCode else {
                return
            }
            if statusCode >= 200 {
                UserDefaults.standard.set(username, forKey: self.CHALLONGE_USERNAME_KEY)
                UserDefaults.standard.set(apiKey, forKey: self.CHALLONGE_USERNAME_KEY)
                print("saved credentials")
                DispatchQueue.main.async {
                    self.present(TournamentsViewController(challongeNetworking: networking), animated: true, completion: nil)
                }
            } else if statusCode == 401 {
                let alert = self.createAlert(title: "Incorrect Credentials", message: "Make sure your username and API are correct and try again.")
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = self.createAlert(title: "An Error Occured", message: nil)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func createAlert(title: String?, message: String?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }

    @IBAction func howToGetAnApiKeyPressed(_ sender: UIButton) {
    }
}
