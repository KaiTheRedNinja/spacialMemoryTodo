//
//  EditLocationPopUpView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 21/12/22.
//

import SwiftUI

struct EditLocationPopUpView: View {

    @ObservedObject
    var popUpManager: PopUpManager

    var body: some View {
        ZStack {
            if let location = popUpManager.locationToEdit {
                locationEditView
            } else {
                noLocationErrorView
            }
        }
        .onDisappear {
            // when the pop up completely dissapears, reset the location to edit
            // so that state is always left the same way it was before the pop up was shown
            popUpManager.locationToEdit = nil
        }
    }

    /// The main view for editing things
    @ViewBuilder
    var locationEditView: some View {
        VStack {
            TextField("Location Name", text: .constant("Test Name"))
                .padding(.bottom, 5)
            colourPickerView
                .padding(.bottom, 5)
            cancelSaveOptions
        }
        .padding(10)
    }

    /// The available colours
    var colours: [Color] = [
        .blue,
        .purple,
        .pink,
        .red,
        .orange,
        .yellow,
        .green,
        .gray
    ]

    // TEMP: The selected colour
    @State
    var selectedColour: Color = .gray

    /// The colour select buttons below the title edit
    @ViewBuilder
    var colourPickerView: some View {
        HStack {
            ForEach(0..<colours.count, id: \.hashValue) { index in
                Button {
                    print("Selected index \(index)")
                    selectedColour = colours[index]
                } label: {
                    colours[index]
                        .mask {
                            Circle()
                        }
                        .frame(width: 15, height: 15)
                        .overlay {
                            if selectedColour == colours[index] {
                                Color.white
                                    .mask {
                                        Circle()
                                    }
                                    .frame(width: 5, height: 5)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    /// The error view that is shown when no location is selected
    @ViewBuilder
    var noLocationErrorView: some View {
        VStack {
            Text("ERROR: No Location Selected")
            Button("Exit") {
                exit()
            }
        }
    }

    /// The Cancel and Save buttons at the bottom left of the screen
    @ViewBuilder
    var cancelSaveOptions: some View {
        HStack {
            Spacer()
            Button("Cancel") {
                exit()
            }
            Button("Save") {
                // TODO: Save
                exit()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    func exit() {
        popUpManager.showLocationEditPopup = false
    }
}
