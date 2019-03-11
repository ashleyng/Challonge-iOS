//
//  MatchesPresenterTests.swift
//  ChallongeTests
//
//  Created by Ashley Ng on 3/10/19.
//  Copyright © 2019 AshleyNg. All rights reserved.
//

import XCTest
import ChallongeNetworking
import OHHTTPStubs
@testable import Challonge

class MatchesPresenterTests: XCTestCase {

    private var presenter: MatchesViewPresenter!
    private var mockInteractor: MockMatchesViewInteractor!

    override func setUp() {
        let tournamentId = 12345
        let fakeUsername = "fakeUsername"
        let fakeApiKey = "fakeApiKey"
        
        let networking = ChallongeNetworking(username: fakeUsername, apiKey: fakeApiKey)
        mockInteractor = MockMatchesViewInteractor()
    
        
        
        let tournament = Tournament(dateCreated: "2019-02-02T01:44:57.884-06:00", description: "", gameId: nil, id: tournamentId, name: "Test Tournament", participantsCount: 4, state: .underway, tournamentType: .singleElimination, updatedAt: "2019-02-02T01:44:57.884-06:00", url: URL(string: "https://challonge.com/12345")!, liveImageUrl: URL(string: "https://challonge.com/12345.svg")!)
    
        presenter = MatchesViewPresenter(networking: networking, interactor: mockInteractor, tournament: tournament)
    }
    
    func testLoadMatch() {
        presenter.loadMatch()
        presenter.tappedCellAt(index: 0)
//        let presentTuple = mockInteractor.presentMatchDetailsVCWith
//
//        XCTAssertNotNil(presentTuple?.0)
//        XCTAssertNotNil(presentTuple?.0.id)
//        XCTAssertNotNil(presentTuple?.1)
//        XCTAssertNotNil(presentTuple?.1.id.main)
//        XCTAssertNotNil(presentTuple?.2.id.main)
    }
}

class MockMatchesViewInteractor: MatchesViewInteractor {
    
    var state: MatchesTableViewState? = nil
    func updateState(to state: MatchesTableViewState) {
        self.state = state
    }
    
    var addFilterMenuCalled = false
    func addFilterMenu() {
        self.addFilterMenuCalled = true
    }
    
    var removeFilterMenuCalled = false
    func removeFilterMenu() {
        self.removeFilterMenuCalled = true
    }
    
    var presentMatchDetailsVCWith: (Match, Participant, Participant)? = nil
    func presentMatchDetailsVC(_ match: Match, playerOne: Participant, playerTwo: Participant) {
        presentMatchDetailsVCWith = (match, playerOne, playerTwo)
    }
    
    var showUnsupportedAlertCalled = false
    func showUnsupportedAlert() {
        self.showUnsupportedAlertCalled = true
    }
}
