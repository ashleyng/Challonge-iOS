//
//  PlayingMatchViewModel.swift
//  Challonge
//
//  Created by Ashley Ng on 12/31/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import Foundation
import ChallongeNetworking
import Crashlytics

fileprivate class ParticipantScore {
    private let participant: Participant
    public private(set) var score: Int
    
    public var id: Int {
        return participant.id
    }
    
    public var name: String {
        return participant.name
    }
    
    init(participant: Participant, score: Int = 0) {
        self.participant = participant
        self.score = score
    }
    
    func increaseScore() {
        score += 1
    }
    
    func decreaseScore() {
        score -= 1
    }
}

class PlayingMatchViewModel {
    private let match: Match
    private let player1: ParticipantScore
    private let player2: ParticipantScore
    private let challongeNetworking: ChallongeNetworking
    private var queue: [Int] = []
    
    init(match: Match, player1: Participant, player2: Participant, challongeNetworking: ChallongeNetworking) {
        self.match = match
        self.player1 = ParticipantScore(participant: player1)
        self.player2 = ParticipantScore(participant: player2)
        self.challongeNetworking = challongeNetworking
    }
    
    func getPlayerOneName() -> String {
        return player1.name
    }
    
    func getPlayerTwoName() -> String {
        return player2.name
    }
    
    func increaseScoreForPlayerOne() -> (player1: Int, player2: Int) {
        queue.append(player1.id)
        player1.increaseScore()
        return (player1: player1.score, player2: player2.score)
    }
    
    func increaseScoreForPlayerTwo() -> (player1: Int, player2: Int) {
        queue.append(player2.id)
        player2.increaseScore()
        return (player1: player1.score, player2: player2.score)
    }
    
    func undoScore() -> (player1: Int, player2: Int) {
        guard let participantId = queue.popLast() else {
            return (player1: player1.score, player2: player2.score)
        }
        let participant = participantId == player1.id ? player1 : player2
        participant.decreaseScore()
        return (player1: player1.score, player2: player2.score)
    }
    
    func submitScore(completion: (() -> Void)?) {
        challongeNetworking.setWinnerForMatch(match.tournamentId, matchId: match.id, winnderId: getWinnerId(), score: matchScore(), completion: { match in
            completion?()
        }, onError: { error in
            Answers.logCustomEvent(withName: "ErrorSubmittingScore", customAttributes: [
                "Error": error.localizedDescription
                ])
        })
    }
    
    func canUndo() -> Bool {
        return queue.count > 0
    }
    
    private func getWinnerId() -> Int {
        let winnerId = player1.score > player2.score ? player1.id : player2.id
        return winnerId
    }
    
    private func matchScore() -> String {
        return "\(player1.score)-\(player2.score)"
    }
}
