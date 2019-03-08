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
    func updateState(to state: MatchesViewState)
}


struct MatchesViewPresenter {
    private let tournamentId: Int
    private let networking: ChallongeNetworking
    private weak var interactor: MatchesViewInteractor?
    
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
                self.interactor?.updateState(to: .populated(sortedMatches, participantsDict, self.mapGroupIds(participants: participantsDict), nil))
            }
        }, onError: { error in
            // TODO: memleak?
            self.interactor?.updateState(to: .error(error))
        })
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
