//
//  TournamentsViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking
import Crashlytics

fileprivate enum State {
    case loading
    case populated([Tournament])
    case empty
    case error(Error)

    var currentTournaments: [Tournament] {
        switch self {
        case .loading, .empty, .error:
            return []
        case .populated(let tournaments):
            return tournaments
        }
    }
}

class TournamentsViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()

    private let networking: ChallongeNetworking
    private var state = State.loading {
        didSet {
            updateUI()
        }
    }

    init(challongeNetworking: ChallongeNetworking) {
        networking = challongeNetworking
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TournamentTableViewCell", bundle: nil), forCellReuseIdentifier: "TournamentCell")
        refreshControl.addTarget(self, action: #selector(refreshTournaments(_:)), for: .valueChanged)

        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }

        updateUI()
        fetchTournaments()
    }

    @objc
    private func refreshTournaments(_ sender: Any) {
        fetchTournaments()
    }

    private func fetchTournaments() {
        networking.getAllTournaments(completion: { tournaments in
            self.state = .populated(tournaments)
        }, onError: { error in
            self.state = .error(error)
        })
    }

    private func updateUI() {
        DispatchQueue.main.async {
            switch self.state {
            case .empty, .populated:
                self.loadingIndicator.isHidden = true
                self.tableView.isHidden = false
                self.loadingIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            case .error(let error):
                print("Error: \(error.localizedDescription)")
                Answers.logCustomEvent(withName: "ErrorFetchingTournaments", customAttributes: [
                    "Error": error.localizedDescription
                ])
            case .loading:
                self.loadingIndicator.isHidden = false
                self.tableView.isHidden = true
                self.loadingIndicator.startAnimating()
            }
            self.tableView.reloadData()
        }
    }
}

extension TournamentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.currentTournaments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentCell", for: indexPath) as? TournamentTableViewCell {
            cell.configureWith(state.currentTournaments[indexPath.row])
            return cell
        }
        return TournamentTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tournament = state.currentTournaments[indexPath.row]
        present(MatchesViewController(challongeNetworking: networking, tournament: tournament), animated: true, completion: nil)
    }
}
