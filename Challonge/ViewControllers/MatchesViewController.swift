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

enum MatchesViewState {
    case loading
    case populated([Match], [Int: Participant], [Int: Int], MatchFilterMenu.MenuState?)
    case empty
    case error(Error)

    var currentMatches: [Match] {
        switch self {
        case .loading, .empty, .error:
            return []
        case .populated(let matches, _, _, _):
            return matches
        }
    }

    var currentParticipants: [Int: Participant] {
        switch self {
        case .loading, .empty, .error:
            return [:]
        case .populated(_, let participants, _, _):
            return participants
        }
    }
    
    var groupParticipantIds: [Int: Int] {
        switch self {
        case .loading, .empty, .error:
            return [:]
        case .populated(_, _, let participants, _):
            return participants
        }
    }
}

class MatchesViewController: UIViewController, MatchesViewInteractor {

    @IBOutlet private var matchMenuView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    
    private let filterMenu: MatchFilterMenu
    private let networking: ChallongeNetworking
    private var presenter: MatchesViewPresenter!
    private let tournamentName: String
    private var state = MatchesViewState.loading {
        didSet {
            updateUI()
        }
    }
    
    init(challongeNetworking: ChallongeNetworking, tournament: Tournament) {
        networking = challongeNetworking
        tournamentName = tournament.name
        filterMenu = MatchFilterMenu()
        
        super.init(nibName: nil, bundle: nil)
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
    
    func updateState(to state: MatchesViewState) {
        self.state = state
    }

    private func updateUI() {
        DispatchQueue.main.async {
            switch self.state {
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
}

extension MatchesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.currentMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let matches = state.currentMatches
        let match = matches[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.identifier, for: indexPath) as? MatchTableViewCell {
            cell.configureWith(MatchTableViewCellViewModel(match: match, participants: state.currentParticipants, groupParticipantIds: state.groupParticipantIds))
            return cell
        }
        return MatchTableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        let match = state.currentMatches[indexPath.row]
        guard let playerOneId = match.player1Id, let playerTwoId = match.player2Id,
            let player1 = getParticipant(id: playerOneId), let player2 = getParticipant(id: playerTwoId) else {
            unsupportedTournamentType()
            return
        }
        
        navigationController?.pushViewController(SingleMatchDetailsViewController(match: match, playerOne: player1, playerTwo: player2, networking: networking), animated: true)
    }
    
    private func getParticipant(id: Int) -> Participant? {
        let participants = state.currentParticipants
        if let participant = participants[id] {
            return participant
        } else if let groupId = state.groupParticipantIds[id], let participant = participants[groupId] {
            return participant
        } else {
            return nil
        }
    }

    private func unsupportedTournamentType() {
        let alertController = UIAlertController(title: nil, message: "We currently don't support viewing this match, but don't fret, we're are always working on improving user experience and adding new features.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}
