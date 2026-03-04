# Life Calendar - Product Requirements Document (PRD)

## 1. Project Overview

**Project Name:** Life Calendar  
**Type:** Mobile & Desktop Application (Flutter) with REST API Backend  
**Core Functionality:** A personal productivity tracker that helps users monitor daily activities, custom goals, and bad habits through an annual contribution grid similar to GitHub.  
**Target Users:** Individuals looking to track their daily habits, productivity, and personal growth.

---

## 2. Problem Statement

Users need a unified tool to:

- Track daily activities and tasks
- Set and monitor custom-length goals (7-90 days)
- Combat bad habits by tracking streak-free days
- Visualize their productivity over time through an annual contribution grid

---

## 3. Product Vision

Life Calendar is a cross-platform application that combines:

- GitHub-style contribution visualization
- Todo/Activity management
- Goal tracking with customizable duration
- Bad habit streak tracking

All data is persisted in a PostgreSQL database with JWT authentication.

---

## 4. User Stories

| ID   | User Story                                                                                    | Priority |
| ---- | --------------------------------------------------------------------------------------------- | -------- |
| US01 | As a user, I want to register and login so that my data is secure and personal                | Must     |
| US02 | As a user, I want to add daily activities so that I can track what I do                       | Must     |
| US03 | As a user, I want to mark activities as done so that I can see my progress                    | Must     |
| US04 | As a user, I want to create custom goals (7-90 days) so that I can track long-term objectives | Must     |
| US05 | As a user, I want to check off goal days so that I can see my goal progress                   | Must     |
| US06 | As a user, I want to add bad habits to track so that I can monitor my streaks                 | Must     |
| US07 | As a user, I want to trigger a "relapse" when I fail a bad habit so that my streak resets     | Must     |
| US08 | As a user, I want to see an annual contribution grid so that I can visualize my productivity  | Must     |
| US09 | As a user, I want my session to persist so that I don't have to login every time              | Must     |

---

## 5. Functional Requirements

### 5.1 Authentication

- User registration (email, password, nickname)
- User login with JWT token
- Persistent session using SharedPreferences
- Logout functionality

### 5.2 Activities

- Create daily activities with title
- Mark activities as done/undone
- Delete activities
- Filter activities by date
- Auto-update contribution level on change

### 5.3 Goals

- Create goals with custom duration (1-90 days)
- Set goal title
- Toggle goal days as completed
- View active goals
- Delete goals
- Goals can have multiple active at once

### 5.4 Bad Habits

- Create bad habits to track
- View current streak
- View longest streak achieved
- Trigger relapse (resets streak to 0)
- Increment streak manually
- Delete bad habits
- Auto-update contribution level on relapse/increment

### 5.5 Contribution Grid

- Annual calendar view (Jan-Dec)
- Color-coded levels (0-4):
  - Level 0: 0 activities
  - Level 1: 1-2 activities
  - Level 2: 3-4 activities
  - Level 3: 5-6 activities
  - Level 4: 7+ activities
- Bonus: Each bad habit without relapse adds +1 level (max 2 bonus)
- Today highlighted with border

---

## 6. Technical Architecture

### 6.1 Frontend (Flutter)

```
Frontend/
├── lib/
│   ├── main.dart                 # App entry, providers setup
│   ├── calendar_page.dart        # Main dashboard
│   ├── models/                   # Data models
│   │   ├── user.dart
│   │   ├── activity.dart
│   │   ├── goal.dart
│   │   ├── bad_habit.dart
│   │   └── contribution.dart
│   ├── services/                 # API communication
│   │   ├── api_client.dart       # Dio HTTP client
│   │   ├── auth_service.dart
│   │   ├── activity_service.dart
│   │   ├── goal_service.dart
│   │   ├── bad_habit_service.dart
│   │   └── contribution_service.dart
│   ├── providers/                # State management
│   │   ├── auth_provider.dart
│   │   ├── activity_provider.dart
│   │   ├── goal_provider.dart
│   │   ├── bad_habit_provider.dart
│   │   └── contribution_provider.dart
│   ├── screens/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── widgets/
│       ├── contribution_grid.dart
│       ├── activities_section.dart
│       ├── goals_section.dart
│       └── bad_habits_section.dart
```

**Tech Stack:**

- Flutter 3.x
- Provider (state management)
- Dio (HTTP client)
- SharedPreferences (local storage)

### 6.2 Backend (FastAPI)

```
Backend/
├── app/
│   ├── main.py                   # FastAPI app
│   ├── config.py                 # Settings
│   ├── database.py               # SQLAlchemy setup
│   ├── models/                   # Database models
│   │   ├── user.py
│   │   ├── activity.py
│   │   ├── goal.py
│   │   ├── bad_habit.py
│   │   └── contribution.py
│   ├── schemas/                  # Pydantic models
│   ├── routers/                  # API endpoints
│   │   ├── auth.py
│   │   ├── activities.py
│   │   ├── goals.py
│   │   ├── bad_habits.py
│   │   └── contributions.py
│   └── utils/
│       ├── auth.py               # JWT utilities
│       └── contributions.py      # Contribution calculation
├── requirements.txt
└── .env
```

**Tech Stack:**

- FastAPI (Python 3.12)
- SQLAlchemy (ORM)
- PostgreSQL (Database)
- Pydantic (Data validation)
- python-jose (JWT)
- passlib + bcrypt (Password hashing)

---

## 7. Database Schema

### Tables

| Table           | Columns                                                                          | Description              |
| --------------- | -------------------------------------------------------------------------------- | ------------------------ |
| `users`         | id, email, password_hash, nickname, created_at                                   | User accounts            |
| `activities`    | id, user_id, title, is_done, date, created_at                                    | Daily tasks              |
| `goals`         | id, user_id, title, target_days, start_date, is_active, created_at               | Custom goals             |
| `goal_days`     | id, goal_id, day_number, is_completed, completed_at                              | Goal day tracking        |
| `bad_habits`    | id, user_id, name, current_streak, longest_streak, last_relapse_date, created_at | Habit tracking           |
| `contributions` | id, user_id, date, level                                                         | Annual contribution data |

---

## 8. API Endpoints

### Authentication

| Method | Endpoint         | Description         |
| ------ | ---------------- | ------------------- |
| POST   | `/auth/register` | Register new user   |
| POST   | `/auth/login`    | Login (returns JWT) |
| GET    | `/auth/me`       | Get current user    |

### Activities

| Method | Endpoint           | Description                           |
| ------ | ------------------ | ------------------------------------- |
| GET    | `/activities`      | List activities (filter: date_filter) |
| POST   | `/activities`      | Create activity                       |
| PUT    | `/activities/{id}` | Update activity                       |
| DELETE | `/activities/{id}` | Delete activity                       |

### Goals

| Method | Endpoint           | Description                      |
| ------ | ------------------ | -------------------------------- |
| GET    | `/goals`           | List goals (filter: active_only) |
| POST   | `/goals`           | Create goal                      |
| PUT    | `/goals/{id}`      | Update goal                      |
| PATCH  | `/goals/{id}/days` | Toggle goal day                  |
| DELETE | `/goals/{id}`      | Delete goal                      |

### Bad Habits

| Method | Endpoint                     | Description      |
| ------ | ---------------------------- | ---------------- |
| GET    | `/bad-habits`                | List bad habits  |
| POST   | `/bad-habits`                | Create bad habit |
| PUT    | `/bad-habits/{id}`           | Update bad habit |
| POST   | `/bad-habits/{id}/relapse`   | Trigger relapse  |
| POST   | `/bad-habits/{id}/increment` | Increment streak |
| DELETE | `/bad-habits/{id}`           | Delete bad habit |

### Contributions

| Method | Endpoint                     | Description                       |
| ------ | ---------------------------- | --------------------------------- |
| GET    | `/contributions`             | List contributions (filter: year) |
| GET    | `/contributions/year/{year}` | Get year contributions            |

---

## 9. UI/UX Design

### Theme

- **Mode:** Dark mode
- **Primary Color:** Green (productivity)
- **Accent Colors:**
  - Green Accent (goals, activities)
  - Red Accent (bad habits)

### Layout

- **Desktop:** Two-column layout
  - Left: Annual contribution grid
  - Right: Activities, Goals, Bad Habits
- **Mobile:** Single column with scroll

### Key Screens

1. **Login Screen** - Email + password form
2. **Register Screen** - Email + password + nickname form
3. **Home/Calendar** - Main dashboard with all features

---

## 10. Non-Functional Requirements

- **Performance:** API responses < 500ms
- **Security:** JWT tokens with 30-min expiration
- **Compatibility:** Android, iOS, Web, Desktop (Flutter)
- **Data Persistence:** All data stored in PostgreSQL

---

## 11. Future Enhancements (Out of Scope)

- [ ] Activity categories/tags
- [ ] Goal templates
- [ ] Statistics and analytics
- [ ] Export data (CSV/JSON)
- [ ] Notifications/reminders
- [ ] Multi-language support
- [ ] Dark/Light theme toggle
- [ ] Cloud sync
- [ ] Social features

---

## 12. Milestones

| Milestone | Description                   | Status      |
| --------- | ----------------------------- | ----------- |
| M1        | Backend setup + Database      | ✅ Complete |
| M2        | Authentication (JWT)          | ✅ Complete |
| M3        | Activities CRUD               | ✅ Complete |
| M4        | Goals CRUD                    | ✅ Complete |
| M5        | Bad Habits CRUD + Streaks     | ✅ Complete |
| M6        | Contribution Grid + Auto-calc | ✅ Complete |
| M7        | Frontend Integration          | ✅ Complete |
| M8        | Login/Register Screens        | ✅ Complete |

---

**Document Version:** 1.0  
**Last Updated:** March 4, 2026  
**Author:** Ezquiz0 (JhosueP)
