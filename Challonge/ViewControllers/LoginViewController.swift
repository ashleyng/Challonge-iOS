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
    @IBOutlet private var loginButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicator.isHidden = true
        apiKeyTextField.delegate = self
        if let savedUsername = UserDefaults.standard.string(forKey: UserDefaults.CHALLONGE_USERNAME_KEY),
            let savedApiKey = UserDefaults.standard.string(forKey: UserDefaults.CHALLONGE_API_KEY) {
            print("Found saved credentials")
            testCredentialsAndLogin(username: savedUsername, apiKey: savedApiKey)
        }

        loginButton.roundEdges(withRadius: 10)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        usernameTextField.text = ""
        apiKeyTextField.text = ""
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
            let apiKey = apiKeyTextField.text,
            username.count > 0 && apiKey.count > 0 else {
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
                UserDefaults.standard.set(username, forKey: UserDefaults.CHALLONGE_USERNAME_KEY)
                UserDefaults.standard.set(apiKey, forKey: UserDefaults.CHALLONGE_API_KEY)
                let library_path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
                
                print("library path is \(library_path)")
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(TournamentsViewController(challongeNetworking: networking), animated: true)
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
        self.present(GetApiKeyHelpViewController(), animated: true, completion: nil)
    }
}
