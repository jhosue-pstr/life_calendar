# Life Calendar - AGENTS.md

This file contains guidelines and commands for agents working on this project.

## Project Overview

- **Frontend**: Flutter (Dart) - Mobile & Desktop app
- **Backend**: FastAPI (Python 3.12) - REST API with PostgreSQL
- **Database**: PostgreSQL

---

## Build, Run & Test Commands

### Flutter (Frontend)

```bash
# Navigate to frontend
cd Frontend

# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for specific platforms
flutter build apk          # Android
flutter build ios         # iOS
flutter build web        # Web
flutter build linux      # Linux desktop

# Lint and analyze
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# Build for Linux (production)
flutter build linux --release
```

### FastAPI (Backend)

```bash
# Navigate to backend
cd Backend

# Activate virtual environment
source venv/bin/activate  # or: . venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the development server
uvicorn app.main:app --reload

# Run with custom host/port
uvicorn app.main:app --host 0.0.0.0 --port 8000

# Run tests (if pytest is configured)
pytest
pytest -v                          # Verbose
pytest tests/                      # Specific directory
pytest tests/test_file.py          # Single file
pytest -k "test_name"             # Run tests matching pattern

# Lint with ruff (if installed)
ruff check .

# Type checking with mypy (if installed)
mypy .
```

### Database

```bash
# Create PostgreSQL database
sudo -u postgres createdb life_calendar

# Connect to database
sudo -u postgres psql -d life_calendar

# Check tables
psql -d life_calendar -c "\dt"
```

---

## Code Style Guidelines

### Python (FastAPI Backend)

**Imports**
- Use absolute imports: `from app.routers import auth`
- Group imports: stdlib → third-party → local
- Sort alphabetically within groups

```python
# Correct order
from datetime import datetime, timedelta
from typing import Optional, List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User
from app.schemas.user import UserCreate
from app.utils.auth import get_current_user
```

**Naming Conventions**
- Files: `snake_case.py` (e.g., `user_service.py`)
- Classes: `PascalCase` (e.g., `UserService`)
- Functions/variables: `snake_case` (e.g., `get_user_by_email`)
- Constants: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRIES`)
- Routes: `snake_case` with prefixes (e.g., `/bad-habits`)

**Types**
- Use type hints for all function parameters and return values
- Use `Optional[T]` instead of `T | None` for compatibility
- Import types from `typing` module

```python
def get_user(user_id: int, db: Session = Depends(get_db)) -> Optional[User]:
    ...
```

**Error Handling**
- Use HTTPException for API errors with appropriate status codes
- Return meaningful error messages
- Handle database errors gracefully

```python
from fastapi import HTTPException, status

if not user:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="User not found"
    )
```

**Pydantic Schemas**
- Separate request/response schemas
- Use `BaseModel` for inputs, include `from_attributes = True` for outputs
- Use appropriate field validation (EmailStr, constr, etc.)

**Database Models**
- Use SQLAlchemy with declarative base
- Define relationships using `relationship()`
- Use `cascade="all, delete-orphan"` for dependent entities

---

### Dart/Flutter (Frontend)

**Imports**
- Use package imports: `package:flutter/material.dart`
- Group: dart: → package: → relative
- Sort alphabetically

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'calendar_page.dart';
import 'widgets/contribution_grid.dart';
```

**Naming Conventions**
- Files: `snake_case.dart` (e.g., `user_service.dart`)
- Classes: `PascalCase` (e.g., `UserService`)
- Variables/functions: `camelCase` (e.g., `getUserByEmail`)
- Constants: `kCamelCase` (e.g., `kMaxRetries`)

**Widgets**
- Use `const` constructors when possible
- Separate UI into small, reusable widgets
- Follow Flutter's widget composition pattern
- Use `Consumer` from Provider for reactive updates

**State Management**
- Use StatefulWidget for local state
- Use Provider for global state
- Use `context.watch<T>()` for reactive UI
- Use `context.read<T>()` for one-time reads

**Code Organization**
```
lib/
├── main.dart                 # App entry, providers setup
├── calendar_page.dart        # Main dashboard
├── models/                  # Data models (User, Activity, Goal, etc.)
├── services/                # API services (dio HTTP client)
│   ├── api_client.dart      # Dio configuration, JWT interceptors
│   ├── auth_service.dart
│   ├── activity_service.dart
│   ├── goal_service.dart
│   ├── bad_habit_service.dart
│   └── contribution_service.dart
├── providers/               # State management (Provider/ChangeNotifier)
│   ├── auth_provider.dart
│   ├── activity_provider.dart
│   ├── goal_provider.dart
│   ├── bad_habit_provider.dart
│   └── contribution_provider.dart
├── screens/                # Pages
│   ├── login_screen.dart
│   └── register_screen.dart
└── widgets/                # Reusable widgets
    ├── contribution_grid.dart
    ├── activities_section.dart
    ├── goals_section.dart
    └── bad_habits_section.dart
```

---

## Database Schema

### Tables (PostgreSQL)

| Table | Description |
|-------|-------------|
| `users` | User accounts with email, password_hash, nickname |
| `activities` | Daily tasks with title, is_done, date |
| `goals` | Custom-length goals (7-90 days) |
| `goal_days` | Individual days within a goal |
| `bad_habits` | Habits to track with streak counting |
| `contributions` | Annual contribution grid (like GitHub) |

### Contribution Level Calculation
- Level 0: 0 activities completed
- Level 1: 1-2 activities
- Level 2: 3-4 activities
- Level 3: 5-6 activities
- Level 4: 7+ activities
- Each bad habit without relapse adds +1 level (max 2 bonus)

---

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login (returns JWT)
- `GET /auth/me` - Get current user

### Activities
- `GET /activities` - List activities (filter: date_filter)
- `POST /activities` - Create activity
- `PUT /activities/{id}` - Update activity
- `DELETE /activities/{id}` - Delete activity

### Goals
- `GET /goals` - List goals (filter: active_only)
- `POST /goals` - Create goal (X days)
- `PUT /goals/{id}` - Update goal
- `PATCH /goals/{id}/days` - Toggle goal day
- `DELETE /goals/{id}` - Delete goal

### Bad Habits
- `GET /bad-habits` - List bad habits
- `POST /bad-habits` - Create bad habit
- `PUT /bad-habits/{id}` - Update bad habit
- `POST /bad-habits/{id}/relapse` - Trigger relapse (resets streak)
- `POST /bad-habits/{id}/increment` - Increment streak manually
- `DELETE /bad-habits/{id}` - Delete bad habit

### Contributions
- `GET /contributions` - List contributions (filter: year)
- `GET /contributions/year/{year}` - Get year contributions

---

## Environment Variables

### Backend (.env)
```
DATABASE_URL=postgresql://postgres:123@localhost/life_calendar
SECRET_KEY=your-secret-key-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

---

## Common Tasks

### Adding a new feature (Backend)
1. Create model in `app/models/`
2. Create schema in `app/schemas/`
3. Create router in `app/routers/`
4. Register router in `app/main.py`
5. Add service methods if needed

### Adding a new feature (Flutter)
1. Create model in `lib/models/`
2. Create service in `lib/services/`
3. Create provider in `lib/providers/`
4. Add UI in `lib/widgets/` or update existing pages

### Running the full stack
```bash
# Terminal 1: Backend
cd Backend && source venv/bin/activate && uvicorn app.main:app --reload

# Terminal 2: Frontend
cd Frontend && flutter run
```

---

## Dependencies

### Flutter (pubspec.yaml)
- `provider` - State management
- `dio` - HTTP client
- `shared_preferences` - Local token storage
- `intl` - Date formatting

### Backend (requirements.txt)
- `fastapi` - Web framework
- `uvicorn` - ASGI server
- `sqlalchemy` - ORM
- `psycopg2-binary` - PostgreSQL driver
- `pydantic` - Data validation
- `python-jose` - JWT tokens
- `passlib[bcrypt]` - Password hashing
