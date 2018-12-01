//
//  TournamentsViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking

class TournamentsViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!

    private let networking: ChallongeNetworking

    private var tournaments: [Tournament] = []

    init(challongeNetworking: ChallongeNetworking) {
        networking = challongeNetworking
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        loadingIndicator.isHidden = false
        tableView.isHidden = true
        loadingIndicator.startAnimating()
        fetchTournaments()
    }

    private func fetchTournaments() {
        networking.getAllTournaments(completion: { tournaments in
            self.tournaments = tournaments
            DispatchQueue.main.async {
                self.loadingIndicator.isHidden = true
                self.tableView.isHidden = false
                self.loadingIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }, onError: { _ in
            DispatchQueue.main.async {
                self.loadingIndicator.isHidden = true
                self.tableView.isHidden = false
                self.loadingIndicator.stopAnimating()
            }
        })
    }
}

extension TournamentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournaments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = tournaments[indexPath.row].name
        return cell
    }
}
