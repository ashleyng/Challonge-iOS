//
//  MatchesViewController.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import ChallongeNetworking
import Crashlytics
import SnapKit


class MatchesViewController: UIViewController, MatchesViewInteractor, MatchFilterMenuDelegate {

    @IBOutlet private var matchMenuView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    
    private let filterMenu: MatchFilterMenu
    private let networking: ChallongeNetworking
    private var presenter: MatchesViewPresenter!
    private let tournamentName: String
    
    init(challongeNetworking: ChallongeNetworking, tournament: Tournament) {
        networking = challongeNetworking
        tournamentName = tournament.name
        filterMenu = MatchFilterMenu()
        
        super.init(nibName: nil, bundle: nil)
        filterMenu.delegate = self
        presenter = MatchesViewPresenter(networking: networking, interactor: self, tournament: tournament)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        matchMenuView.addSubview(filterMenu)
        filterMenu.snp.makeConstraints { make in
            make.top.bottom.right.left.equalTo(matchMenuView)
        }
        navigationItem.title = tournamentName
        tableView.register(UINib(nibName: MatchTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: MatchTableViewCell.identifier)

        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshMatches(_:)), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadMatch()
    }

    @objc
    private func refreshMatches(_ sender: Any) {
        presenter.loadMatch()
    }
    
    func updateState(to state: MatchesTableViewState) {
        DispatchQueue.main.async {
            switch state {
            case .empty, .populated:
                self.tableView.isHidden = false
                self.loadingIndicator.isHidden = true
                self.refreshControl.endRefreshing()
                self.loadingIndicator.stopAnimating()
            case .error(let error):
                Answers.logCustomEvent(withName: "ErrorFetchingMatches", customAttributes: [
                    "Error": error.localizedDescription
                    ])
            case .loading:
                self.tableView.isHidden = true
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
            }
            self.tableView.reloadData()
        }
    }
    
    func filterDidChange(newFilter: MatchFilterMenu.MenuState) {
        presenter.filterDidChange(newFilter: newFilter)
    }
}

extension MatchesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.matchesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.identifier, for: indexPath) as? MatchTableViewCell {
            let viewModel = presenter.viewModelFor(index: indexPath.row)
            cell.configureWith(viewModel)
            return cell
        }
        return MatchTableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        guard let matchVM = presenter.matchesViewModelAt(index: indexPath.row) else {
            unsupportedTournamentType()
            return
        }
        navigationController?.pushViewController(SingleMatchDetailsViewController(match: matchVM.match, playerOne: matchVM.playerOne, playerTwo: matchVM.playerTwo, networking: networking), animated: true)
    }

    private func unsupportedTournamentType() {
        let alertController = UIAlertController(title: nil, message: "We currently don't support viewing this match, but don't fret, we're are always working on improving user experience and adding new features.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}
