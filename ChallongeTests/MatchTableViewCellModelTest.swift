//
//  MatchTableViewCellModelTests.swift
//  ChallongeTests
//
//  Created by Ashley Ng on 2/24/19.
//  Copyright © 2019 AshleyNg. All rights reserved.
//

import XCTest
import ChallongeNetworking
@testable import Challonge

class MatchTableViewCellModelTest: XCTestCase {
    var viewModel: MatchViewModel!
    let participants = [
        12: Participant(name: "Player One", tournamentId: 4567, icon: nil, id: Participant.Id(main: 12, group: [])),
        23: Participant(name: "Player Two", tournamentId: 4567, icon: nil, id: Participant.Id(main: 23, group: []))
    ]

    override func setUp() {
        let completeMatch = match(with: .complete)
        self.viewModel = MatchViewModel(match: completeMatch, mappedMatches: [completeMatch.id: completeMatch], participants: participants)
    }

    func testMatchLabel() {
        let expectedMatchLabel = "Match 3"
        let actualMatchLabel = viewModel.matchLabel()
        XCTAssertEqual(expectedMatchLabel, actualMatchLabel)
    }
    
    func testCompletedMatchScoreLabels() {
        let expectedPlayerOneScore = "5"
        let expectedPlayerTwoScore = "3"
        let actualPlayerOneScore = viewModel.playerOneStatus()
        let actualPlayerTwoScore = viewModel.playerTwoStatus()
        
        XCTAssertEqual(expectedPlayerOneScore, actualPlayerOneScore)
        XCTAssertEqual(expectedPlayerTwoScore, actualPlayerTwoScore)
    }
    
    func testOpenMatchStatusLabel() {
        // TODO: Find a better way to do this.
        let openMatch = match(with: .open)
        self.viewModel = MatchViewModel(match: openMatch, mappedMatches: [openMatch.id: openMatch], participants: participants)
        
        let expectedLabel = "open"
        let actualLabel = viewModel.matchStatus()
        XCTAssertEqual(expectedLabel, actualLabel)
    }
    
    func testOpenMatchPlayerStatusLabel() {
        // TODO: Find a better way to do this.
        let openMatch = match(with: .open)
        self.viewModel = MatchViewModel(match: openMatch, mappedMatches: [openMatch.id: openMatch], participants: participants)
        
        let expectedLabel = "open"
        let actualPlayerOneStatus = viewModel.playerOneStatus()
        let actualPlayerTwoStatus = viewModel.playerTwoStatus()
        
        XCTAssertEqual(expectedLabel, actualPlayerOneStatus)
        XCTAssertEqual(expectedLabel, actualPlayerTwoStatus)
    }
    
    func testCompletedLabelColor() {
        let expectedColor = UIColor.completedGreen
        let actualColor = viewModel.statusLabelColor()
        XCTAssertEqual(expectedColor, actualColor)
    }
    
    func testOpenLabelColor() {
        // TODO: Find a better way to do this.
        let openMatch = match(with: .open)
        self.viewModel = MatchViewModel(match: openMatch, mappedMatches: [openMatch.id: openMatch], participants: participants)
        
        let expectedColor = UIColor.gray
        let actualColor = viewModel.statusLabelColor()
        XCTAssertEqual(expectedColor, actualColor)
    }
    
    func testPendingLabelColor() {
        // TODO: Find a better way to do this.
        let pendingMatch =  match(with: .pending)
        self.viewModel = MatchViewModel(match: pendingMatch, mappedMatches: [pendingMatch.id: pendingMatch], participants: participants)
        
        let expectedColor = UIColor.red
        let actualColor = viewModel.statusLabelColor()
        XCTAssertEqual(expectedColor, actualColor)
    }
    
    private func match(with state: Match.State) -> Match {
        let scoreCsv = state == .complete ? "5-3" : nil
        let winnerId = state == .complete ? 12 : nil
        let preReq = Match.PreReqInformation(player1MatchId: nil, player2MatchId: nil, player1MatchIsLoser: false, player2MatchIsLoser: false)
        return Match(id: 1234, player1Id: 12, player2Id: 23, state: state, tournamentId: 4567, winnerId: winnerId, scoresCsv: scoreCsv, suggestedPlayOrder: 3, player1Votes: nil, player2Votes: nil, groupId: nil, round: 1, preReqInfo: preReq)
    }

}
