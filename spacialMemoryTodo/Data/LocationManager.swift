//
//  LocationManager.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 26/12/22.
//

import SwiftUI
import macAppBoilerplate

class LocationManager: macAppBoilerplate.TabBarItemRepresentable, ObservableObject {

    init(fromDisk: Bool = true, autoSaveToDisk: Bool = true) {
        if fromDisk {
            loadLocationsFromPath()
        }

        if autoSaveToDisk {
            autoSave()
        }
    }

    func autoSave() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.saveLocationsToPath()
            self.autoSave()
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

    func saveLocationsToPath(path: URL? = nil) {
        let path = path ?? locationsURL

        Log.info("Trying to write to path \(path)")

        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(locations) else {
            Log.info("Writing failed")
            return
        }

        Log.info("Write success: \(data)")
        try? data.write(to: path, options: .atomic)
    }

    @discardableResult
    func loadLocationsFromPath(path: URL? = nil) -> Bool {
        let path = path ?? locationsURL

        // check that file exists
        Log.info("Trying to read from path \(path)")
        guard filemanager.fileExists(atPath: path.path) else {
            // if the file doesn't exist, make sure that the folder exists so that the file
            // can be written there
            try? filemanager.createDirectory(at: baseURL, withIntermediateDirectories: false)
            Log.info("Path does not exist. Creating folder.")
            return false
        }

        // decode the json
        guard let json = try? Data(contentsOf: path),
              let locs = try? JSONDecoder().decode([Location].self, from: json)
        else {
            return false
        }

        // load the locations
        Log.info("Successfully loaded locations")
        self.locations = locs

        return true
    }
}
