//
//  LocationManager.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 26/12/22.
//

import SwiftUI
import macAppBoilerplate

class LocationManager: macAppBoilerplate.TabBarItemRepresentable, ObservableObject {

    init(fromDisk: Bool = true) {
        if fromDisk {
            loadLocationsFromPath()
        }
    }

    // tab item representable things
    var tabID: macAppBoilerplate.TabBarID = TabID.mainContent
    var title: String = "MainContent"
    var icon: NSImage = NSImage(systemSymbolName: "circle", accessibilityDescription: nil)!
    var iconColor: Color = .accentColor

    // the locations
    @Published var locations: [Location] = []

    // the selection
    @Published var selectedLocation: Location?
    @Published var selectedTodo: Todo?

    // used for creating new locations
    var locationForNewTodo: ((CGSize) -> CGPoint)?

    // do not allow saving while another save operation is happening
    var saveIsHappening: Bool = false
}

// MARK: Save and load
private let filemanager = FileManager.default
extension LocationManager {

    /// The base URL of preferences.
    ///
    /// The base folder url `~/Library/Application Support/com.kaitay.spacialMemoryTodo/`
    public var baseURL: URL {
        guard let url = try? filemanager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            return filemanager.homeDirectoryForCurrentUser
                .appendingPathComponent("Library")
                .appendingPathComponent("Application Support")
                .appendingPathComponent("com.kaitay.spacialMemoryTodo")
        }

        return url.appendingPathComponent(
            "com.kaitay.spacialMemoryTodo",
            isDirectory: true
        )
    }

    /// The URL for locations
    public var locationsURL: URL {
        baseURL.appendingPathComponent("locations.json")
    }

    private func saveLocationsToPath(path: URL? = nil) {
        guard !saveIsHappening else { return }
        saveIsHappening = true
        let path = path ?? locationsURL

        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(locations) else {
            return
        }

        try? data.write(to: path, options: .atomic)
        saveIsHappening = false
    }

    @discardableResult
    private func loadLocationsFromPath(path: URL? = nil) -> Bool {
        let path = path ?? locationsURL

        // check that file exists
        guard filemanager.fileExists(atPath: path.path) else {
            // if the file doesn't exist, make sure that the folder exists so that the file
            // can be written there
            try? filemanager.createDirectory(at: baseURL, withIntermediateDirectories: false)
            return false
        }

        // decode the json
        guard let json = try? Data(contentsOf: path),
              let locs = try? JSONDecoder().decode([Location].self, from: json)
        else {
            return false
        }

        // load the locations
        self.locations = locs

        return true
    }

    static func save(sender: NSView) {
        guard let window = sender.window?.windowController as? MainWindowController
        else { return }

        save(sender: window.tabManager)
    }

    static func save(sender: TabManager) {
        guard let manager = sender.openedTabs.first as? LocationManager
        else { return }

        // do the saving asyncly to avoid lag
        DispatchQueue.main.async {
            manager.saveLocationsToPath()
        }
    }
}
