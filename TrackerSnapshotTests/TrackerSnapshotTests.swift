//
//  TrackerSnapshotTests.swift
//  TrackerAppTests
//
//  Created by Maksim on 23.01.2025.
//

//

import SnapshotTesting
import XCTest

@testable import TrackerApp

final class SnapshotTests: XCTestCase {
    func testViewController() throws {
        let vc = TrackersViewController(trackerStore: TrackerStore.shared)
        
        vc.overrideUserInterfaceStyle = .light
        assertSnapshot(of: vc, as: .image, named: "LightMode")
        
        vc.overrideUserInterfaceStyle = .dark
        assertSnapshot(of: vc, as: .image, named: "DarkMode")
    }
}
