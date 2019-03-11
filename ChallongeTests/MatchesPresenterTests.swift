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
    private var networking: ChallongeNetworking!
    
    let tournamentId = 12345
    let fakeUsername = "fakeUsername"
    let fakeApiKey = "fakeApiKey"

    override func setUp() {
        networking = ChallongeNetworking(username: fakeUsername, apiKey: fakeApiKey)
        mockInteractor = MockMatchesViewInteractor()
    
        stub(condition: isAbsoluteURLString("https://\(fakeUsername):\(fakeApiKey)@api.challonge.com/v1/tournaments/\(tournamentId)/matches.json")) { _ in
            let stubPath = OHPathForFile("Matches.json", type(of: self))
            return fixture(filePath: stubPath!, headers: nil)
        }
        
        stub(condition: isAbsoluteURLString("https://\(fakeUsername):\(fakeApiKey)@api.challonge.com/v1/tournaments/\(tournamentId)/participants.json")) { _ in
            let stubPath = OHPathForFile("Participants.json", type(of: self))
            return fixture(filePath: stubPath!, headers: nil)
        }
    
        presenter = MatchesViewPresenter(networking: networking, interactor: mockInteractor, tournament: setupTournament(withType: .singleElimination))
        presenter.loadMatch()
        sleep(5) // This is dumb. TODO: Fix this
    }
    
    func testTappedCell() {
        presenter.tappedCellAt(index: 0)
        let presentTuple = mockInteractor.presentMatchDetailsVCWith

        XCTAssertNotNil(presentTuple?.0)
        XCTAssertNotNil(presentTuple?.0.id)
        XCTAssertNotNil(presentTuple?.1)
        XCTAssertNotNil(presentTuple?.1.id.main)
        XCTAssertNotNil(presentTuple?.2.id.main)
    }
    
    func testTappedUnsupportedMatch() {
        presenter.tappedCellAt(index: 5)
        
        XCTAssertTrue(mockInteractor.showUnsupportedAlertCalled)
    }
    
    func testRemoveFilterMenu() {
        presenter.viewDidLoad()
        
        XCTAssertFalse(mockInteractor.addFilterMenuCalled)
        XCTAssertTrue(mockInteractor.removeFilterMenuCalled)
    }
    
    func testAddFilterMenu() {
        presenter = MatchesViewPresenter(networking: networking, interactor: mockInteractor, tournament: setupTournament(withType: .doubleElimination))
        presenter.loadMatch()
        sleep(5) // This is dumb. TODO: Fix this
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(mockInteractor.addFilterMenuCalled)
        XCTAssertFalse(mockInteractor.removeFilterMenuCalled)
    }
    
    func testFilterDidChangeToWinner() {
        presenter.filterDidChange(newFilter: .winner)
        
        switch mockInteractor.state! {
        case .populated(let viewModels):
            XCTAssertTrue(viewModels.count == 4)
        default:
            XCTFail()
        }
    }
    
    func testFilterDidChangeToLoser() {
        presenter.filterDidChange(newFilter: .loser)
        
        switch mockInteractor.state! {
        case .populated(let viewModels):
            XCTAssertTrue(viewModels.count == 2)
        default:
            XCTFail()
        }
    }
    
    func testFilterDidChangeToAll() {
        presenter.filterDidChange(newFilter: .all)
        
        switch mockInteractor.state! {
        case .populated(let viewModels):
            XCTAssertTrue(viewModels.count == 6)
        default:
            XCTFail()
        }
    }
    
    private func setupTournament(withType type: Tournament.TournamentType) -> Tournament {
        return Tournament(dateCreated: "2019-02-02T01:44:57.884-06:00", description: "", gameId: nil, id: tournamentId, name: "Test Tournament", participantsCount: 4, state: .underway, tournamentType: type, updatedAt: "2019-02-02T01:44:57.884-06:00", url: URL(string: "https://challonge.com/12345")!, liveImageUrl: URL(string: "https://challonge.com/12345.svg")!)
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
