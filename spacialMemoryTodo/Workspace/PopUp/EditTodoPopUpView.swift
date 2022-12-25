//
//  EditTodoPopUpView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 21/12/22.
//

import SwiftUI

struct EditTodoPopUpView: View {

    @ObservedObject
    var popUpManager: PopUpManager

    var body: some View {
        ZStack {
            if popUpManager.todoToEdit != nil {
                todoEditView
            } else {
                noTodoErrorView
            }
        }
        .onDisappear {
            // when the pop up completely dissapears, reset the todoo to edit
            // so that state is always left the same way it was before the pop up was shown
            popUpManager.todoToEdit = nil
        }
    }

    @State var newName: String = "Untitled Todo"

    /// The main view for editing things
    @ViewBuilder
    var todoEditView: some View {
        VStack {
            TextField("Todo Name", text: $newName)
                .padding(.bottom, 5)
                .onAppear {
                    newName = popUpManager.todoToEdit?.name ?? ""
                }
                .onSubmit {
                    save()
                }
            cancelSaveOptions
        }
        .padding(10)
    }

    /// The error view that is shown when no todo is selected
    @ViewBuilder
    var noTodoErrorView: some View {
        VStack {
            Text("ERROR: No Todo Selected")
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
                save()
            }
            // disable the save button if there is no name
            .disabled(newName.isEmpty)
            .buttonStyle(.borderedProminent)
        }
    }

    /// Exits and saves
    func save() {
        if let todo = popUpManager.todoToEdit {
            todo.name = newName
            todo.objectWillChange.send()
        }
        exit()
    }

    /// Exits but does not save
    func exit() {
        popUpManager.showTodoEditPopup = false
    }
}
