//
//  MatchesPresenter.swift
//  Challonge
//
//  Created by Ashley Ng on 2/24/19.
//  Copyright © 2019 AshleyNg. All rights reserved.
//

import Foundation
import ChallongeNetworking

protocol MatchesViewInteractor: class {
    func updateState(to state: MatchesTableViewState)
}

// TODO: Not actually a ViewModel. Fix me.
struct SingleMatchViewModel {
    let match: Match
    let playerOne: Participant
    let playerTwo: Participant
}


class MatchesViewPresenter {
    
    private let tournamentId: Int
    private let networking: ChallongeNetworking
    private weak var interactor: MatchesViewInteractor?
    private var state = MatchesTableViewState.loading {
        didSet {
            interactor?.updateState(to: state)
        }
    }
    
    init(networking: ChallongeNetworking, interactor: MatchesViewInteractor, tournament: Tournament) {
        self.tournamentId = tournament.id
        self.interactor = interactor
        self.networking = networking
    }
    
    func loadMatch() {
        self.interactor?.updateState(to: .loading)
        networking.getMatchesForTournament(tournamentId, completion: { matches in
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
                // TODO: memleak?
                self.state = .populated(sortedMatches, participantsDict, self.mapGroupIds(participants: participantsDict), nil)
            }
        }, onError: { error in
            // TODO: memleak?
            self.state = .error(error)
        })
    }
    
    func matchesCount() -> Int {
        return state.filteredMatches.count
    }
    
    func viewModelFor(index: Int) -> MatchTableViewCellViewModel {
        let match = state.filteredMatches[index]
        return MatchTableViewCellViewModel(match: match, participants: state.currentParticipants, groupParticipantIds: state.groupParticipantIds)
    }
    
    func filterDidChange(newFilter: MatchFilterMenu.MenuState) {
        print("Delegate filterDidChange(newFilter:)")
        state = .populated(state.allMatches, state.currentParticipants, state.groupParticipantIds, newFilter)
    }
    
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
        networking.getParticipantsForTournament(tournamentId, completion: { (participants: [Participant]) in
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
