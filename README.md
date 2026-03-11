<div align="center">

# 🎓 Campus AI

**A smart campus companion app powered by AI — built with Flutter, FastAPI, and Supabase.**

Ask about events, schedules, campus info, and more — all through an intelligent chat interface.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi)
![Supabase](https://img.shields.io/badge/Supabase-Database%20%26%20Auth-3ECF8E?logo=supabase)

</div>

---

## 📋 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Setup Guide](#-setup-guide)
  - [1. Supabase Setup](#1-supabase-setup)
  - [2. Backend Setup](#2-backend-setup)
  - [3. Student App Setup](#3-student-app-setup)
  - [4. Admin App Setup](#4-admin-app-setup)
- [Automation (VS Code)](#-automation-vs-code)
- [Deployment](#-deployment)
- [Contributing](#-contributing)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🤖 **AI Chat** | Ask campus-related questions powered by Gemini/Groq LLM |
| 🎤 **Voice Input** | Speak your questions using speech-to-text |
| 📅 **Event Manager** | Browse events in the Student App; Create/Edit them in the **Admin App** |
| ❓ **FAQ Builder** | Manage the AI's knowledge base via the Admin App |
| 🔐 **Admin Portal** | Restricted access for campus staff to manage data securely |
| 💬 **Chat History** | Persistent chat sessions saved to Supabase |
| 🌗 **Dark Mode** | Material 3 adaptive theming |

---

## 🏗 Architecture

```
┌─────────────────┐      ┌──────────────────┐      ┌───────────────┐
│   Student App   │ ───→ │  FastAPI Backend  │ ───→ │   Supabase    │
│   (Flutter)     │      │   (Python API)    │      │  (DB + Auth)  │
└─────────────────┘      └──────────────────┘      └───────────────┘
                                 ↑                         ↑
┌─────────────────┐              │                         │
│    Admin App    │ ─────────────┴─────────────────────────┘
│   (Management)  │
└─────────────────┘
```

---

## 📁 Project Structure

- `frontend/`: Original student-facing Flutter application.
- `admin_app/`: **[NEW]** Administrative mobile app for managing Events and FAQs.
- `backend/`: FastAPI server (Primary: Gemini, Fallback: Groq).
- `supabase_migration.sql`: Core database schema.
- `admin_setup.sql`: SQL snippet to enable Admin roles and security.

---

## 🚀 Setup Guide

### 1. Supabase Setup
1. Run `supabase_migration.sql` in the SQL Editor.
2. Run `admin_setup.sql` to enable roles.
3. **Important**: Promte yourself to admin by running:
   ```sql
   UPDATE public.users SET role = 'admin' WHERE email = 'YOUR_EMAIL';
   ```

### 2. Backend Setup (Render.com)
The backend is optimized for Render.
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- Set `PYTHON_VERSION` to `3.11.0` in Environment Variables.

### 3. Student App Setup
```bash
cd frontend
flutter run --dart-define-from-file=.env
```

### 4. Admin App Setup
Dedicated app for staff to manage the database.
```bash
cd admin_app
flutter run --dart-define-from-file=.env
```

---

## 🤖 Automation (VS Code)
Both apps include a `.vscode/launch.json`. You can simply press **F5** in VS Code to run the apps; it will automatically include your `.env` secrets.

---

## 🌐 Deployment
- **Backend**: Hosted on Render at `https://campus-ai-backend-wlpn.onrender.com`.
- **Database**: Managed on Supabase.
- **APK**: Build via `flutter build apk --release --dart-define-from-file=.env`.

---

<div align="center">

**Built with ❤️ for ICFAI University, Tripura**

</div>
p.main:app --host 0.0.0.0 --port 8000 --reload
```

**Terminal 2 — Frontend:**
```bash
cd frontend
flutter run --dart-define-from-file=.env
```

---

## 🌐 Deployment

See [`DEPLOYMENT.md`](DEPLOYMENT.md) for production deployment instructions including:
- **Backend** → Render.com (free tier)
- **Local tunneling** → ngrok for demos
- **APK builds** → Release APK generation

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is built as a university major project at **ICFAI University, Tripura**.

---

<div align="center">

**Built with ❤️ by Atanu Paul**

</div>
