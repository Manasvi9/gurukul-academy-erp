# Architecture

## Foundation Scope

This phase establishes project infrastructure only. It does not implement authentication or any school business feature.

## Principles

- Feature-first Clean Architecture.
- Riverpod for dependency injection and state management.
- GoRouter for navigation.
- Material 3 for consistent UI.
- Backend-owned authorization and business rules.
- Flutter is treated as an untrusted client.

## Source Layout

```text
lib/
  main.dart
  src/
    app/
    core/
    shared/
    features/
```

`core` contains app-wide infrastructure.

`shared` contains reusable UI and presentation helpers.

`features` contains feature folders. Business feature logic is added only after explicit approval.

## Feature Shape

```text
features/<feature>/
  data/
    datasources/
    dto/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    providers/
    screens/
    widgets/
```
