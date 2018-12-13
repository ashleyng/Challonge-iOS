//
//  GetApiKeyHelpWebView.swift
//  Challonge
//
//  Created by Ashley Ng on 12/10/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SnapKit

class GetApiKeyHelpViewController: UIViewController {

    private var webViewContainer: UIView!
    private var webView: WKWebView!
    private var backButton: UIButton = UIButton()
    private var navContainerView: UIView = UIView(frame: .zero)
    private var webViewContainerView: UIView = UIView()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavContainer()
        setupWebViewContainer()
        backButton.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)

        let url = URL(string: "https://api.challonge.com/v1")
        let request = URLRequest(url: url!)
        webView.load(request)
    }

    private func setupNavContainer() {
        navContainerView.backgroundColor = UIColor.white

        navContainerView.addSubview(backButton)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(UIColor.blue, for: .normal)
        backButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(8)
        }

        self.view.addSubview(navContainerView)
        navContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(48)
        }
    }

    private func setupWebViewContainer() {
        webViewContainerView = UIView(frame: .zero)
        webViewContainerView = webView

        self.view.addSubview(webViewContainerView)
        webViewContainerView.snp.makeConstraints { make in
            make.top.equalTo(navContainerView.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
    }

    @objc
    private func backButtonPressed(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
