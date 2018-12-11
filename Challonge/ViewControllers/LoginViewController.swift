//
//  LoginViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking
import Fabric
import Crashlytics

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var apiKeyTextField: UITextField!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButtonBottomConstraint: NSLayoutConstraint!

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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc
    func keyboardWillShow(notification: NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        loginButtonBottomConstraint.constant = keyboardFrame.size.height + 20
    }

    @objc
    func keyboardWillHide(notification: NSNotification) {
        loginButtonBottomConstraint.constant = 218
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        guard let username = usernameTextField.text,
            let apiKey = apiKeyTextField.text else {
            return
        }
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()

        testCredentialsAndLogin(username: username, apiKey: apiKey) {
            DispatchQueue.main.async {
                self.loadingIndicator.isHidden = true
                self.loadingIndicator.stopAnimating()
            }
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
                DispatchQueue.main.async {
                    self.present(TournamentsViewController(challongeNetworking: networking), animated: true, completion: nil)
                }
            } else if statusCode == 401 {
                let alert = self.createAlert(title: "Incorrect Credentials", message: "Make sure your username and API are correct and try again.")
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                Answers.logCustomEvent(withName: "LoginFailed", customAttributes: [
                    "StatusCode": statusCode
                ])
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
