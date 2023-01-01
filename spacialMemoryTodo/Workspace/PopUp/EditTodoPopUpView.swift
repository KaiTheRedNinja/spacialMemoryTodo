//
//  EditTodoPopUpView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 21/12/22.
//

import SwiftUI
import macAppBoilerplate

struct EditTodoPopUpView: View {

    @ObservedObject
    var tabManager: TabManager

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
    @State var creationDate: Date = .now
    @State var dueDate: Date?

    /// The main view for editing things
    @ViewBuilder
    var todoEditView: some View {
        VStack {
            TextField("Todo Name", text: $newName)
                .padding(.bottom, 5)
                .onSubmit {
                    save()
                }
            HStack {
                Text("Creation Date:")
                    .bold()
                    .frame(width: 100, alignment: .trailing)
                Image(systemName: "lock")
                Text("\(creationDate.formatted())")
                Spacer()
            }
            .foregroundColor(.gray)
            HStack {
                Text("Due Date:")
                    .bold()
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100, alignment: .trailing)
                Button {
                    // TODO: Edit due date
                } label: {
                    if let dueDate {
                        Text("\(dueDate.formatted())")
                    } else {
                        Text("No Due Date")
                    }
                }
                Spacer()
            }
            cancelSaveOptions
        }
        .padding(10)
        .onAppear {
            guard let todo = popUpManager.todoToEdit else { return }
            newName = todo.name
            creationDate = todo.creationDate
            dueDate = todo.dueDate
        }
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
        defer { exit() }
        guard let todo = popUpManager.todoToEdit else { return }

        todo.name = newName
        todo.objectWillChange.send()

        LocationManager.save(sender: tabManager)
    }

    /// Exits but does not save
    func exit() {
        popUpManager.showTodoEditPopup = false
    }
}
