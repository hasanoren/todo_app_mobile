# Research: FEAT-05 — Todo Lists (Görev Listeleri)

## API Investigation & Contracts

### Endpoints
1. `POST /api/TodoLists`
   - Headers: `Authorization: Bearer <token>`
   - Body: `{ "name": "Work", "colorCode": "#3B82F6" }`
   - Response 201: `TodoListResponse`
2. `GET /api/TodoLists`
   - Headers: `Authorization: Bearer <token>`
   - Response 200: `CollectionResponse<TodoListResponse>` -> `{ "items": [ { "id": "...", "name": "...", "colorCode": "...", "ownerId": "...", "createdAt": "...", "updatedAt": null } ] }`
3. `GET /api/TodoLists/{id}`
   - Headers: `Authorization: Bearer <token>`
   - Response 200: `TodoListResponse`
4. `PUT /api/TodoLists/{id}`
   - Headers: `Authorization: Bearer <token>`
   - Body: `{ "name": "Work Updated", "colorCode": "#10B981" }`
   - Response 200: `TodoListResponse`
5. `DELETE /api/TodoLists/{id}`
   - Headers: `Authorization: Bearer <token>`
   - Response 204: No Content

### Architectural Placement
- We will organize the code under `lib/features/todo_lists/`:
  - `data/models/`:
    - `todo_list_response_dto.dart`
    - `create_todo_list_request.dart`
    - `update_todo_list_request.dart`
  - `data/datasources/`:
    - `todo_lists_remote_data_source.dart`
  - `domain/entities/`:
    - `todo_list.dart`
  - `domain/repositories/`:
    - `todo_lists_repository.dart`
  - `data/repositories/`:
    - `todo_lists_repository_impl.dart`
  - `presentation/cubits/`:
    - `todo_lists_cubit.dart` & `todo_lists_state.dart`
    - `todo_list_form_cubit.dart` & `todo_list_form_state.dart`
  - `presentation/screens/`:
    - `todo_lists_screen.dart`
  - `presentation/widgets/`:
    - `todo_list_card.dart`
    - `color_picker_grid.dart`
    - `todo_list_form_modal.dart`

### Color Palette Strategy
- Hex strings with `#` prefix (max 7 chars, e.g., `#3B82F6`).
- Pre-defined palette of vibrant, accessible Material/Tailwind colors:
  - Indigo (`#6366F1`)
  - Blue (`#3B82F6`)
  - Cyan (`#06B6D4`)
  - Emerald (`#10B981`)
  - Amber (`#F59E0B`)
  - Rose (`#F43F5E`)
  - Purple (`#A855F7`)
  - Slate (`#64748B`)
- Helper extension to convert between Flutter `Color` and hex string `#RRGGBB`.
