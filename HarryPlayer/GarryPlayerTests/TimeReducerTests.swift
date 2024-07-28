//
//  TimeReducerTests.swift
//  GarryPlayerTests
//
//  Created by Oleksii on 28.07.2024.
//

import XCTest
import ComposableArchitecture
@testable import GarryPlayer

final class TimeReducerTests: XCTestCase {

    var bookPlayer: MockBookPlayer!
    var store: TestStore<TimeReducer.State, TimeReducer.Action>!
    
    override func setUpWithError() throws {
        
        bookPlayer = MockBookPlayer()
        
        store = TestStore(
            initialState: TimeReducer.State(player: bookPlayer!, currentTime: 15)) {
                TimeReducer()
            }
    }
    
    override func tearDownWithError() throws {
        
        bookPlayer = nil
        store = nil
    }
    
    func testTimeChanged() async {
        
        let newTime: TimeInterval = 10.0
        
        await store.send(.timeChanged(newTime)) {
            $0.currentTime = newTime
        }
    }
    
    func testForceTimeUpdateOn() async {
        
        await store.send(.forceTimeUpdateOn(-10)) {
            $0.currentTime = 5.0
            XCTAssertEqual(self.bookPlayer.currentTime, 5.0)
        }
        
        await store.send(.forceTimeUpdateOn(10)) {
            $0.currentTime = 15.0
            XCTAssertEqual(self.bookPlayer.currentTime, 15.0)
        }
        
        await store.send(.forceTimeUpdateOn(50)) {
            $0.currentTime = 65.0
            XCTAssertEqual(self.bookPlayer.currentTime, 65.0)
        }
        
        await store.send(.forceTimeUpdateOn(-65)) {
            $0.currentTime = 0.0
            XCTAssertEqual(self.bookPlayer.currentTime, 0.0)
        }
        
        await store.send(.forceTimeUpdateOn(1000)) {
            $0.currentTime = $0.totalTime
            XCTAssertEqual(self.bookPlayer.currentTime, $0.totalTime)
        }
        
        await store.send(.forceTimeUpdateOn(-1000)) {
            $0.currentTime = 0.0
            XCTAssertEqual(self.bookPlayer.currentTime, 0.0)
        }
    }
    
    func testForceTimeRefresh() async {
        
        bookPlayer.currentTime = 30.0
        bookPlayer.duration = 100.0
        
        await store.send(.forceTimeRefresh) {
            $0.currentTime = 0.0
            $0.totalTime = 100.0
            XCTAssertEqual(self.bookPlayer.currentTime, 0.0)
        }
    }
    
    func testUpdateTime() async {
        
        bookPlayer.currentTime = 20.0
        bookPlayer.isPlaying = true
        
        await store.send(.updateTime) {
            $0.currentTime = 20.0
        }
    }
    
    func testButtonsAvailable() async {
        
        XCTAssertEqual(store.state.isTimeBackButtonAvailable, true)
        XCTAssertEqual(store.state.isTimeForwardButtonAvailable, true)
                       
        await store.send(.forceTimeUpdateOn(-1000)) {
            $0.currentTime = 0
            XCTAssertEqual($0.isTimeBackButtonAvailable, false)
            XCTAssertEqual($0.isTimeForwardButtonAvailable, true)
        }
        
        await store.send(.forceTimeUpdateOn(1000)) {
            $0.currentTime = $0.totalTime
            XCTAssertEqual($0.isTimeBackButtonAvailable, true)
            XCTAssertEqual($0.isTimeForwardButtonAvailable, false)
        }
        
        await store.send(.forceTimeRefresh) {
            $0.currentTime = 0
            XCTAssertEqual($0.isTimeBackButtonAvailable, false)
            XCTAssertEqual($0.isTimeForwardButtonAvailable, true)
        }
    }
}
