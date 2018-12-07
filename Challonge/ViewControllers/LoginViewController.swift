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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.isHidden = true
        apiKeyTextField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        defer {
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
        }

        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        guard let username = usernameTextField.text,
            let apiKey = apiKeyTextField.text else {
            return
        }

        let networking = ChallongeNetworking(username: username, apiKey: apiKey)
        networking.checkCredentials() { [weak self] statusCode in
            guard let `self` = self, let statusCode = statusCode, statusCode >= 200 else {
                print("FAILED")
                return
            }
            print("SUCCESS")
            DispatchQueue.main.async {
                self.present(TournamentsViewController(challongeNetworking: networking), animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func howToGetAnApiKeyPressed(_ sender: UIButton) {
    }
}
