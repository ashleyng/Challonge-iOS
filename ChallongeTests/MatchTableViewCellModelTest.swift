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
    var viewModel: MatchTableViewCellViewModel!
    let participants = [
        12: Participant(name: "Player One", tournamentId: 4567, icon: nil, id: Participant.Id(main: 12, group: [])),
        23: Participant(name: "Player Two", tournamentId: 4567, icon: nil, id: Participant.Id(main: 23, group: []))
    ]

    override func setUp() {
        self.viewModel = MatchTableViewCellViewModel(match: match(with: .complete), participants: participants, groupParticipantIds: [:])
    }

    func testMatchLabel() {
        let expectedMatchLabel = "Player One vs. Player Two"
        let actualMatchLabel = viewModel.matchLabel()
        XCTAssertEqual(expectedMatchLabel, actualMatchLabel)
    }
    
    func testCompletedMatchStatusLabel() {
        let expectedLabel = "5-3"
        let actualLabel = viewModel.matchStatusLabelText()
        XCTAssertEqual(expectedLabel, actualLabel)
    }
    
    func testOpenMatchStatusLabel() {
        // TODO: Find a better way to do this.
        self.viewModel = MatchTableViewCellViewModel(match: match(with: .open), participants: participants, groupParticipantIds: [:])
        
        let expectedLabel = "open"
        let actualLabel = viewModel.matchStatusLabelText()
        XCTAssertEqual(expectedLabel, actualLabel)
    }
    
    func testCompletedLabelColor() {
        let expectedColor = UIColor.completedGreen
        let actualColor = viewModel.statusLabelColor()
        XCTAssertEqual(expectedColor, actualColor)
    }
    
    func testOpenLabelColor() {
        // TODO: Find a better way to do this.
        self.viewModel = MatchTableViewCellViewModel(match: match(with: .open), participants: participants, groupParticipantIds: [:])
        
        let expectedColor = UIColor.gray
        let actualColor = viewModel.statusLabelColor()
        XCTAssertEqual(expectedColor, actualColor)
    }
    
    func testPendingLabelColor() {
        // TODO: Find a better way to do this.
        self.viewModel = MatchTableViewCellViewModel(match: match(with: .pending), participants: participants, groupParticipantIds: [:])
        
        let expectedColor = UIColor.red
        let actualColor = viewModel.statusLabelColor()
        XCTAssertEqual(expectedColor, actualColor)
    }
    
    private func match(with state: Match.State) -> Match {
        let scoreCsv = state == .complete ? "5-3" : nil
        let winnerId = state == .complete ? 12 : nil
        return Match(id: 1234, player1Id: 12, player2Id: 23, state: state, tournamentId: 4567, winnerId: winnerId, scoresCsv: scoreCsv, suggestedPlayOrder: 3, player1Votes: nil, player2Votes: nil, groupId: nil, round: 1)
    }

}
