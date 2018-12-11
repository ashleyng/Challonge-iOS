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

class GetApiKeyHelpViewController: UIViewController, WKUIDelegate {

    private var webView: WKWebView!
    private var backButton: UIButton = UIButton()
    private var navContainerView: UIView = UIView()
    private var webViewContainerView: UIView = UIView()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        webView.uiDelegate = self
        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.addSubview(navContainerView)
//        self.view.addSubview(backButton)
//        self.view.addSubview(webViewContainerView)
//
//        navContainerView.snp.makeConstraints { make in
//            make.top.left.right.equalTo(view)
//            make.height.equalTo(48)
//        }
//        backButton.snp.makeConstraints { make in
//            make.left.equalTo(navContainerView).offset(8)
//            make.centerY.equalTo(navContainerView.center)
//        }
//        webViewContainerView.snp.makeConstraints { make in
//            make.top.equalTo(navContainerView.snp_bottomMargin)
//            make.left.right.bottom.equalTo(view)
//        }
        
        let url = URL(string: "https://api.challonge.com/v1")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
}
