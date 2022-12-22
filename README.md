# spacialMemoryTodo
A macOS todo app making use of spacial memory

**THIS APP IS IN DEVELOPMENT. NOT ALL FEATURES MAY BE COMPLETE OR FUNCTIONAL.**

## The Concept
### Backstory
I recently moved to a larger house, where my room was four flights of stairs up from where I work.
Walking up and down every time I needed to get something, move something, do something, would be impractical.

That led to me to almost always forget what I needed to do, as by the time I would go up to my room I would forget
the other things that I need to do up there. This app was intended to solve that issue by latching onto my spacial memory.

### Spacial Memory
Spacial Memory Todo (tentative name) allows the user to create "locations", in my case one for each room in my house, and rearrange them visually.
This makes more intuitive sense; If I want to go up to a higher floor, I just check the corresponding card, which would be in an appropriate location.
As opposed to other todo/reminders systems, this app allows you to more easily access what you need to do simply because all your todos are in a visual
space corresponding to one that you are already familar with.

## Terminology
- `Location`: A data structure, usually representing a location (eg. a room in a house) holding `Todo`s that are related to that location
- `Todo`: A checklist item. Usually belongs to a certain `Location`
- `Canvas`: Where all the `Location`s are laid out visually
- `Card`: The visual representation of a single `Location` in the `Canvas`
- `Sidebar`: A linear representation of all the `Locations` and their `Todo`

## Features

### Completed Features
- Sidebar for locations/todos, similar to regular todo apps
- Infinite-space 2D Canvas for laying out locations
- Location cards
  - `Todo` list view within the card
  - Dragging and resizing
  - Editing the title
  - Editing the name
  - Deleting locations

### Todo
- Adding locations
- Adding todos
- Deleting todos
- Rearranging locations (in sidebar)
- Rearranging todos
- Local storage

## Building
1. Clone this repository
2. Open `spacialMemoryTodo.xcodeproj` in Xcode
3. Click on `File -> Packages -> Update to Latest Package Versions` to fetch the dependencies
4. Press the play button in the top left to run the application
