//
//  SidebarNavigatorViewToolbar.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 1/1/23.
//

import SwiftUI

struct SidebarNavigatorViewToolbar: View {

    @Environment(\.colorScheme) var colorScheme

    @State
    var hideCompletedTodos: Bool = false

    @State
    var searchTerm: String = ""

    var body: some View {
        VStack {
            HStack {
                HStack {
                    toggleCompletedTodoVisibility
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

    var toggleCompletedTodoVisibility: some View {
        Button {
            hideCompletedTodos.toggle()
        } label: {
            Image(systemName: "checkmark.square\(hideCompletedTodos ? "" : ".fill")")
        }
        .help("\(hideCompletedTodos ? "Show" : "Hide") completed todos")
        .buttonStyle(.borderless)
        .offset(x: 3)
    }
}
