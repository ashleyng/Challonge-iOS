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


class MatchesViewPresenter {
    
    private let tournament: Tournament
    private let networking: ChallongeNetworking
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
                let participantsDict = participants.toDictionary { $0.id.main }
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
                let filter = self.state.currentFilter ?? .all
                self.state = .populated(sortedMatches, participantsDict, self.mapGroupIds(participants: participantsDict), filter)
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
            "oldFilter": state.currentFilter?.rawValue ?? ""
        ])

        state = .populated(state.allMatches, state.currentParticipants, state.groupParticipantIds, newFilter)
    }
    
    // NOT MVP
    func matchesViewModelAt(index: Int) -> SingleMatchViewModel? {
        let match = state.filteredMatches[index]
    
        guard let playerOne = participantFor(id: match.player1Id), let playerTwo = participantFor(id: match.player2Id) else {
            return nil
        }
        
        return SingleMatchViewModel(match: match, playerOne: playerOne, playerTwo: playerTwo)
    }
    
    private func participantFor(id: Int?) -> Participant? {
        guard let id = id else {
            return nil
        }
        
        if let participant = state.currentParticipants[id] {
            return participant
        } else if let groupId = state.groupParticipantIds[id], let participant = state.currentParticipants[groupId] {
            return participant
        } else {
            return nil
        }
    }
    
    private func fetchParticipants(completion: @escaping ([Participant]) -> Void) {
        networking.getParticipantsForTournament(tournament.id, completion: { (participants: [Participant]) in
            completion(participants)
        }, onError: { _ in })
    }
    
    private func mapGroupIds(participants: [Int: Participant]) -> [Int: Int] {
        var dict = [Int: Int]()
        participants.forEach { (participantId, participant) in
            participant.id.all.forEach{ groupId in
                dict[groupId] = participantId
            }
        }
        return dict
    }
}

enum MatchesTableViewState {
    case loading
    case populated([Match], [Int: Participant], [Int: Int], MatchFilterMenu.MenuState?)
    case empty
    case error(Error)
}

extension MatchesTableViewState {
    func viewModels() -> [MatchTableViewCellViewModel] {
        switch self {
        case .populated:
            return filteredMatches.map { match in
                return MatchTableViewCellViewModel(match: match, mappedMatches: mappedMatch, participants: currentParticipants, groupParticipantIds: groupParticipantIds)
            }
        default:
            return []
        }
        
    }
}

fileprivate extension MatchesTableViewState {
    var allMatches: [Match] {
        switch self {
        case .loading, .empty, .error:
            return []
        case .populated(let matches, _, _, _):
            return matches
        }
    }
    
    var mappedMatch: [Int: Match] {
        switch self {
        case .loading, .empty, .error:
            return [:]
        case .populated(let matches, _, _, _):
            return matches.toDictionary(with: { $0.id })
        }
    }
    
    var filteredMatches: [Match] {
        switch self {
        case .loading, .empty, .error:
            return []
        case .populated(let matches, _, _, let filter):
            return matches.filter { match in
                switch filter {
                case .all?:
                    return true
                case .winner?:
                    return match.round > 0
                case .loser?:
                    return match.round < 0
                default: return true
                }
            }
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
    
    var currentFilter: MatchFilterMenu.MenuState? {
        switch self {
        case .loading, .empty, .error:
            return nil
        case .populated(_, _, _, let filter):
            return filter
        }
    }
}

