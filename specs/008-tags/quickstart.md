# Quickstart: FEAT-08 — Tags & Categorization

## Overview
1. Tag endpoints added to `ApiConstants`.
2. Data models created: `TagResponseDto`, `TagsCollectionResponseDto`, `CreateTagRequest`.
3. `TagsRemoteDataSource` & `TagsRepository` implemented.
4. `TagsCubit` managing system tags and task tags attachment/detachment.
5. `TaggedTasksCubit` managing infinite-scroll task browsing for a specific tag.
6. UI widgets: `TagChip`, `TaskTagsSection`, `TagSelectorBottomSheet`, `CreateTagDialog`.
7. Screen: `TaggedTasksScreen` allowing users to view and interact with tasks filtered by a tag.
8. Integrated into `TaskCard` and `TaskDetailScreen`.

