# User Model Notes

## Overview
Food tracking app for calorie/nutrition tracking. Multiple users with simple username/password auth.

## User Schema

**Table:** `users`

| Field | Type | Purpose |
|-------|------|---------|
| `username` | string | Unique login identifier |
| `pass_hash` | string | Bcrypt password hash |
| `config` | map | JSON config for user preferences |
| `inserted_at` | datetime | Ecto timestamp |
| `updated_at` | datetime | Ecto timestamp |

### Default Config Structure

```json
{
  "daily_calorie_goal": 2000,
  "daily_protein_goal": null,
  "daily_carb_goal": null,
  "daily_fat_goal": null
}
```

## Auth Approach

- Simple username + password
- No email (no verification, no recovery)
- Manual DB edit for account recovery if needed
- Bcrypt hashing via Comeonin/Phoenix.Authentication

## Design Decisions

- Replaced individual preference fields with single `config` JSON map
- Avoids migrations for adding new user settings
- Flexible for future features (goals, units, preferences)
- `config` defaults to empty map `%{}`

## To Generate

```bash
mix phx.gen.schema User users username:string pass_hash:string config:map
```

## Future Considerations

- May need `is_active` boolean for soft delete (add later)
- Profile fields (height, weight, etc.) can go in config or separate table
- Consider separate `user_settings` table if config grows complex
