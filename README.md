# 🎓 University Management Platform (DAM Project)

A university management platform with three roles — **admin**, **teacher** and **student** — built with a Flutter mobile app and a Node.js/Express + PostgreSQL backend.

> University team project.

---

## Features

- 🔐 **Authentication** — sign up / sign in with JWT
- ✅ **Admin approval** — admins accept or reject new users
- 🏫 **Academic management** — programs, groups and modules CRUD
- 👩‍🏫 **Teacher space** — teacher dashboard and module views
- 🎓 **Student space** — student dashboard
- 📱 **Mobile app** — Flutter frontend with GetX, go_router and shared preferences
- 🗄️ **PostgreSQL** database with SQL schema (`backend/db/schema.sql`)

---

## Tech stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter, Dart, GetX, go_router, http, shared_preferences |
| Backend | Node.js, Express 5, PostgreSQL (`pg`), JWT, CORS |
| Database | PostgreSQL |

---

## Project structure

```
.
├── frontend/                 # Flutter application
│   ├── lib/                  # screens, controllers, services
│   └── pubspec.yaml
├── backend/                  # Express API
│   ├── routes/
│   │   ├── auth/             # signup, signin
│   │   ├── admin/            # users, groups, programs, modules, students
│   │   ├── teacher/
│   │   ├── student/
│   │   └── token/
│   ├── db/schema.sql
│   └── server.js
```

---

## Getting started

### Backend

```bash
cd backend
npm install
```

Create `backend/.env`:

```env
PORT=3001
DATABASE_URL=postgresql://user:password@localhost:5432/university
JWT_SECRET=replace-with-a-long-random-secret
```

Create the schema and start the API:

```bash
psql -U postgres -d university -f db/schema.sql
node server.js
```

### Flutter app

```bash
cd frontend
flutter pub get
flutter run
```

> Update the API base URL in the app configuration to point to your backend.

---

## Roadmap

- [ ] Refresh tokens and role-based middleware
- [ ] Absence and grade management
- [ ] Push notifications
- [ ] Dark mode
- [ ] Unit and widget tests

---

## Team

University team project. See the commit history for contributors.

---

## License

MIT — see the [LICENSE](LICENSE) file.
