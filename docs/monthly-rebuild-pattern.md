# Monthly Rebuild Pattern

The **monthly rebuild** is a key pattern in this repo: instead of nursing long-lived snowflake environments, we rebuild from code on a regular cadence.

## Goals

- Limit attacker dwell time and persistence.
- Eliminate configuration drift.
- Enforce a consistent, known-good baseline.
- Test automation regularly.

## High-Level Flow

1. Refresh images/templates.
2. Apply IaC (Citrix / NetScaler).
3. Run smoke tests.
4. Cut over traffic.
5. Decommission old resources.
