# Coding Conventions

- Do not hardcode environment-specific values.
- Keep business rules out of Flutter.
- Treat Flutter validation as user-experience validation only.
- Enforce sensitive rules on the backend.
- Return typed failures instead of leaking raw exceptions into UI.
- Provide loading, error, empty, and offline states for network-driven screens.
- Prefer immutable models.
- Keep widgets focused and reusable.
- Keep feature dependencies inward-facing: presentation depends on domain, data implements domain contracts.
- Do not move to the next feature until the current feature is approved.
