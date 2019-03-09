//
//  MatchesPresenter.swift
//  Challonge
//
//  Created by Ashley Ng on 2/24/19.
//  Copyright © 2019 AshleyNg. All rights reserved.
//

import Foundation
import ChallongeNetworking
import Crashlytics

protocol MatchesViewInteractor: class {
    func updateState(to state: MatchesTableViewState)
    func addFilterMenu()
    func removeFilterMenu()
}

// TODO: Not actually a ViewModel. Fix me.
struct SingleMatchViewModel {
    let match: Match
    let playerOne: Participant
    let playerTwo: Participant
}

enum MatchesTableViewState {
    case loading
    case populated([MatchViewModel])
    case empty
    case error(Error)
}


class MatchesViewPresenter {
    
    private let tournament: Tournament
    private let networking: ChallongeNetworking
    
    private var filter: MatchFilterMenu.MenuState = .all
    private var matches: [Match] = []
    private var participants: [Int: Participant] = [:]
    
    private var filteredMatches: [Match] {
        return matches.filter { match in
            switch filter {
            case .all:
                return true
            case .winner:
                return match.round > 0
            case .loser:
                return match.round < 0
            }
        }
    }
    
    private weak var interactor: MatchesViewInteractor?
    private var state = MatchesTableViewState.loading {
        didSet {
            interactor?.updateState(to: state)
        }
    }
    
    init(networking: ChallongeNetworking, interactor: MatchesViewInteractor, tournament: Tournament) {
        self.tournament = tournament
        
        self.interactor = interactor
        self.networking = networking
    }
    
    func viewDidLoad() {
        if tournament.tournamentType == .doubleElimination {
            self.interactor?.addFilterMenu()
        } else {
            self.interactor?.removeFilterMenu()
        }
    }
    
    func loadMatch() {
        self.interactor?.updateState(to: .loading)
        networking.getMatchesForTournament(tournament.id, completion: { matches in
            self.fetchParticipants() { participants in
                let sortedMatches = matches.sorted(by: { left, right in
                    // TODO need to check these bools
                    guard let leftSuggestedPlayOrder = left.suggestedPlayOrder else {
                        return false
                    }
                    guard let rightSuggestedPlayOrder = right.suggestedPlayOrder else {
                        return true
                    }
                    return leftSuggestedPlayOrder < rightSuggestedPlayOrder
                })
                self.matches = sortedMatches
                self.participants = self.participantsToDictionary(participants: participants)
                let viewModels = self.filteredMatches.map { match in
                    return MatchViewModel(match: match, mappedMatches: matches.toDictionary(with: { $0.id }), participants: self.participants)
                }
                self.state = .populated(viewModels)
            }
        }, onError: { error in
            Answers.logCustomEvent(withName: "ErrorFetchingMatches", customAttributes: [
                "Error": error.localizedDescription
            ])
            self.state = .error(error)
        })
    }
    
    func filterDidChange(newFilter: MatchFilterMenu.MenuState) {
        Answers.logCustomEvent(withName: "User changed filter", customAttributes: [
            "newFilter": newFilter.rawValue,
            "oldFilter": filter
        ])
        filter = newFilter
        let viewModels = filteredMatches.map { match in
            return MatchViewModel(match: match, mappedMatches: matches.toDictionary(with: { $0.id }), participants: participants)
        }
        state = .populated(viewModels)
    }
    
    // NOT MVP
    func matchesViewModelAt(index: Int) -> SingleMatchViewModel? {
        let match = filteredMatches[index]
    
        guard let playerOne = participantFor(id: match.player1Id), let playerTwo = participantFor(id: match.player2Id) else {
            return nil
        }
        
        return SingleMatchViewModel(match: match, playerOne: playerOne, playerTwo: playerTwo)
    }
    
    private func participantFor(id: Int?) -> Participant? {
        guard let id = id else {
            return nil
        }
        return participants[id]
    }
    
    private func participantsToDictionary(participants: [Participant]) -> [Int: Participant] {
        var participantsDict = participants.toDictionary { $0.id.main }
        participantsDict.values.forEach { participant in
            participant.id.all.forEach{ groupId in
                participantsDict[groupId] = participant
            }
        }
        return participantsDict
    }
    
    private func fetchParticipants(completion: @escaping ([Participant]) -> Void) {
        networking.getParticipantsForTournament(tournament.id, completion: { (participants: [Participant]) in
            completion(participants)
        }, onError: { _ in })
    }
}
