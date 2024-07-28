//
//  SpeedReducerTests.swift
//  GarryPlayerTests
//
//  Created by Oleksii on 28.07.2024.
//

@testable import GarryPlayer

import XCTest
import ComposableArchitecture

final class SpeedReducerTests: XCTestCase {
    
    var speeds: [Double] { [1.25, 1.5, 2.0, 0.5, 0.75, 1.0, 1.25] }
    
    var bookPlayer: (any BookPlayer)!
    var store: TestStore<SpeedReducer.State, SpeedReducer.Action>!
    
    override func setUpWithError() throws {
        bookPlayer = MockBookPlayer()
        store = TestStore(
            initialState: SpeedReducer.State(player: bookPlayer!)) {
                SpeedReducer()
            }
    }
    
    override func tearDownWithError() throws {
        bookPlayer = nil
        store = nil
    }
    
    func testSpeedButtonTapped() async {
        
        XCTAssertEqual(self.bookPlayer.speed, 1.0)
        
        for speed in speeds {
            
            await store.send(.speedButtonTapped) {
                $0.currentSpeed = speed
                XCTAssertEqual(self.bookPlayer.speed, speed)
            }
        }
    }
}
