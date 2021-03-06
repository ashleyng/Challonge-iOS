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
        return participant.id.main
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
    private var usersFlipped: Bool = false
    private var queue: [Int] = []
    
    init(match: Match, player1: Participant, player2: Participant, challongeNetworking: ChallongeNetworking) {
        self.match = match
        self.player1 = ParticipantScore(participant: player1)
        self.player2 = ParticipantScore(participant: player2)
        self.challongeNetworking = challongeNetworking
    }
    
    func getPlayerNames() -> (player1: String, player2: String) {
        let playerTuple = participantTuple()
        return (player1: playerTuple.0.name, player2: playerTuple.1.name)

    }
    
    func increaseScoreForPlayerOne() {
        let player = participantTuple().0
        queue.append(player.id)
        player.increaseScore()
    }
    
    func increaseScoreForPlayerTwo() {
        let player = participantTuple().1
        queue.append(player.id)
        player.increaseScore()
    }
    
    func undoScore() {
        guard let participantId = queue.popLast() else {
            return
        }
        let participant = participantId == player1.id ? player1 : player2
        participant.decreaseScore()
    }
    
    func getScore() -> (player1: Int, player2: Int) {
        let playerTuple = participantTuple()
        return (player1: playerTuple.0.score, player2: playerTuple.1.score)
    }
    
    func flipUsers() {
        usersFlipped = !usersFlipped
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
    
    private func participantTuple() -> (ParticipantScore, ParticipantScore) {
        if usersFlipped {
            return (player2, player1)
        } else {
            return (player1, player2)
        }
    }
    
    private func getWinnerId() -> Int {
        let winnerId = player1.score > player2.score ? player1.id : player2.id
        return winnerId
    }
    
    private func matchScore() -> String {
        return "\(player1.score)-\(player2.score)"
    }
}
