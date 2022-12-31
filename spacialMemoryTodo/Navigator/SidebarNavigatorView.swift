//
//  SidebarNavigatorView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate

struct SidebarNavigatorView: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject
    var tabManager: TabManager

    @ObservedObject
    var popUpManager: PopUpManager

    @State
    var hideCompletedTodos: Bool = false

    @State
    var searchTerm: String = ""

    var body: some View {
        VStack {
            OutlineView { _ in
                let view = NavigatorOutlineView()
                view.popUpManager = popUpManager
                return view
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                HStack {
                    HStack {
                        sortButton
                        TextField("Filter", text: $searchTerm)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12))
                        if !searchTerm.isEmpty {
                            Button {
                                searchTerm = ""
                            } label: {
                                Image(systemName: "xmark")
                            }
                            .font(.system(size: 12))
                            .buttonStyle(.borderless)
                            .padding(.trailing, 3)
                        }
                    }
                    .padding(.vertical, 3)
                    .background(colorScheme == .dark ? Color(hex: "#FFFFFF").opacity(0.1) :
                                    Color(hex: "#808080").opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 0.5).cornerRadius(6))
                    .padding(.trailing, 3)
                    .padding(.leading, 5)
                }
                .frame(height: 29, alignment: .center)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .top) {
                    Divider()
                }
            }
            .padding(.top, -8)
        }
    }

    var sortButton: some View {
        Menu {
            Button {
                hideCompletedTodos.toggle()
            } label: {
                Text("\(hideCompletedTodos ? "Show" : "Hide") Completed Todos")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
        .menuStyle(.borderlessButton)
        .frame(maxWidth: 30)
        .opacity(1)
        .onAppear {
            let locationManager = LocationManager.default
            hideCompletedTodos = locationManager.hideCompletedTodos
            searchTerm = locationManager.searchTerm
        }
        .onChange(of: hideCompletedTodos) { newValue in
            let locationManager = LocationManager.default
            locationManager.hideCompletedTodos = newValue
        }
        .onChange(of: searchTerm) { newValue in
            let locationManager = LocationManager.default
            locationManager.searchTerm = newValue
        }
    }
}

public extension Color {

    /// Initializes a `Color` from a HEX String (e.g.: `#1D2E3F`) and an optional alpha value.
    /// - Parameters:
    ///   - hex: A String of a HEX representation of a color (format: `#1D2E3F`)
    ///   - alpha: A Double indicating the alpha value from `0.0` to `1.0`
    init(hex: String, alpha: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(hex: Int(int), alpha: alpha)
    }

    /// Initializes a `Color` from an Int (e.g.: `0x1D2E3F`)and an optional alpha value.
    /// - Parameters:
    ///   - hex: An Int of a HEX representation of a color (format: `0x1D2E3F`)
    ///   - alpha: A Double indicating the alpha value from `0.0` to `1.0`
    init(hex: Int, alpha: Double = 1.0) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(.sRGB, red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, opacity: alpha)
    }
}
