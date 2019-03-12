//
//  PlayingMatchViewModelTests.swift
//  ChallongeTests
//
//  Created by Ashley Ng on 2/22/19.
//  Copyright © 2019 AshleyNg. All rights reserved.
//

import XCTest
// TODO: This should probably not be needed for unit tests
import ChallongeNetworking
@testable import Challonge

class PlayingMatchViewModelTests: XCTestCase {
    var viewModel: PlayingMatchViewModel!

    override func setUp() {
        let preReq = Match.PreReqInformation(player1MatchId: nil, player2MatchId: nil, player1MatchIsLoser: false, player2MatchIsLoser: false)
        let match = Match(id: 1234, player1Id: 23, player2Id: 24, state: .open, tournamentId: 4567, winnerId: nil, scoresCsv: nil, suggestedPlayOrder: nil, player1Votes: nil, player2Votes: nil, groupId: nil, round: 1, preReqInfo: preReq)
        let player1 = Participant(name: "Participant One", tournamentId: 4567, icon: nil, id: Participant.Id(main: 23, group: []))
        let player2 = Participant(name: "Participant Two", tournamentId: 4567, icon: nil, id: Participant.Id(main: 24, group: []))
        
        viewModel = PlayingMatchViewModel(match: match, player1: player1, player2: player2, challongeNetworking: ChallongeNetworking(username: "username", apiKey: "apikey"))
    }

    func testGetPlayerNames() {
        let actualPlayerNames = viewModel.getPlayerNames()
        let expectedPlayerNames = (player1: "Participant One", player2: "Participant Two")
        
        XCTAssertEqual(actualPlayerNames.player1, expectedPlayerNames.player1)
        XCTAssertEqual(actualPlayerNames.player2, expectedPlayerNames.player2)
    }
    
    func testIncreasePlayerOneScore() {
        let expectedPlayerOneScore = 2
        viewModel.increaseScoreForPlayerOne()
        viewModel.increaseScoreForPlayerOne()
        
        XCTAssertEqual(viewModel.getScore().player1, expectedPlayerOneScore)
    }
    
    func testIncreasePlayerTwoScore() {
        let expectedPlayerTwoScore = 1
        viewModel.increaseScoreForPlayerTwo()
        
        XCTAssertEqual(viewModel.getScore().player2, expectedPlayerTwoScore)
    }
    
    func testUndoScore() {
        let expectedScoresBeforeUndo = (player1: 3, player2: 2)
        let expectedScoresAfterUndo = (player1: 1, player2: 2)
        viewModel.increaseScoreForPlayerOne()
        viewModel.increaseScoreForPlayerTwo()
        viewModel.increaseScoreForPlayerTwo()
        viewModel.increaseScoreForPlayerOne()
        viewModel.increaseScoreForPlayerOne()
        
        let actualScoresBeforeUndo = viewModel.getScore()
        XCTAssertEqual(actualScoresBeforeUndo.player1, expectedScoresBeforeUndo.player1)
        XCTAssertEqual(actualScoresBeforeUndo.player2, expectedScoresBeforeUndo.player2)
        
        viewModel.undoScore()
        viewModel.undoScore()
        
        let actualScoresAfterUndos = viewModel.getScore()
        XCTAssertEqual(actualScoresAfterUndos.player1, expectedScoresAfterUndo.player1)
        XCTAssertEqual(actualScoresAfterUndos.player2, expectedScoresAfterUndo.player2)
    }
    
    func testCanUndo() {
        XCTAssertFalse(viewModel.canUndo())
        viewModel.increaseScoreForPlayerTwo()
        XCTAssertTrue(viewModel.canUndo())
    }
    
    func testFlipUserNames() {
        let expectedPlayerNames = (player1: "Participant Two", player2: "Participant One")
        viewModel.flipUsers()
        
        let actualPlayerNames = viewModel.getPlayerNames()
        XCTAssertEqual(actualPlayerNames.player1, expectedPlayerNames.player1)
        XCTAssertEqual(actualPlayerNames.player2, expectedPlayerNames.player2)
    }
    
    func testFlipUserScores() {
        let expectedPlayerScores = (player1: 2, player2: 1)
        viewModel.increaseScoreForPlayerOne()
        viewModel.increaseScoreForPlayerTwo()
        viewModel.increaseScoreForPlayerTwo()
        
        viewModel.flipUsers()
        
        let actualPlayerScores = viewModel.getScore()
        XCTAssertEqual(actualPlayerScores.player1, expectedPlayerScores.player1)
        XCTAssertEqual(actualPlayerScores.player2, expectedPlayerScores.player2)
    }

}
