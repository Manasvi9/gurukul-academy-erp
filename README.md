# Gurukul Academy ERP

Production-ready, mobile-first School ERP foundation for Gurukul Academy.

Authentication and business modules are intentionally not implemented in this phase.

## Security Position

Flutter is an untrusted client. It handles UI, validation, state management, and user interactions only.

Sensitive operations and business rules must be verified by Row Level Security, backend SQL policies, and Supabase Edge Functions where necessary.

## Local Setup

Create `.env` from `.env.example` and provide public runtime configuration.

Never place service-role keys, JWT signing secrets, database passwords, or admin credentials in Flutter assets.
