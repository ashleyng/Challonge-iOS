//
//  LoginViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking

class LoginViewController: UIViewController {

    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var apiKeyTextField: UITextField!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.isHidden = true
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
        networking.checkCredentials() { statusCode in
            guard let statusCode = statusCode, statusCode >= 200 else {
                print("FAILED")
                return
            }
            print("SUCCESS")
        }
        
    }
    
    @IBAction func howToGetAnApiKeyPressed(_ sender: UIButton) {
    }
}
