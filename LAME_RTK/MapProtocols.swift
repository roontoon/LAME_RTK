//
//  MapProtocols.swift
//  YourApp
//
//  Created by Your Name on Date
//  Date and Time Documented: October 17, 2023, 12:30 PM
//
//  Overview:
//  This file contains various protocols related to map functionality.
//

// MARK: - MapZoomDelegate Protocol Definition
/// Protocol to define the contract for zooming actions in the map.
protocol MapZoomDelegate {
    /// Function to handle zoom-in action on the map.
    func zoomIn()

    /// Function to handle zoom-out action on the map.
    func zoomOut()
}
