<div align="center">

# 🎓 Campus AI Assistant

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
  - [3. Frontend Setup](#3-frontend-setup)
- [Running the App](#-running-the-app)
- [Deployment](#-deployment)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🤖 **AI Chat** | Ask campus-related questions powered by Gemini/Groq LLM |
| 🎤 **Voice Input** | Speak your questions using speech-to-text |
| 🔊 **Text-to-Speech** | Listen to AI responses read aloud |
| 📅 **Campus Events** | Browse upcoming and past campus events with filtering |
| 🔐 **Authentication** | Secure user login/signup via Supabase Auth |
| 💬 **Chat History** | Persistent chat sessions saved to Supabase |
| 🌗 **Dark/Light Mode** | Material 3 dynamic theming with system preference support |

---

## 🏗 Architecture

```
┌─────────────────┐      ┌──────────────────┐      ┌───────────────┐
│   Flutter App   │ ───→ │  FastAPI Backend  │ ───→ │   Supabase    │
│   (Frontend)    │      │   (Python API)    │      │  (DB + Auth)  │
└─────────────────┘      └──────────────────┘      └───────────────┘
                                │
                                │ LLM API
                                ▼
                         ┌──────────────┐
                         │ Gemini/Groq  │
                         │   (AI/LLM)   │
                         └──────────────┘
```

---

## 🧰 Tech Stack

### Frontend (Mobile App)
- **Flutter 3.x** — Cross-platform mobile framework
- **Riverpod** — State management
- **Supabase Flutter** — Auth & database client
- **Dio** — HTTP client for API calls
- **Google Fonts (Inter)** — Typography
- **Speech-to-Text / Flutter TTS** — Voice features
- **Material 3** — Modern UI with dynamic theming

### Backend (API Server)
- **FastAPI** — High-performance Python web framework
- **Supabase Python SDK** — Database operations
- **Google Gemini / Groq** — LLM for AI chat responses
- **Pydantic** — Data validation & settings management
- **Uvicorn** — ASGI server

### Database & Auth
- **Supabase (PostgreSQL)** — Hosted database with Row Level Security
- **Supabase Auth** — Email/password authentication

---

## 📁 Project Structure

```
CampusAI/
├── backend/                    # FastAPI backend server
│   ├── app/
│   │   ├── main.py             # App entry point, CORS, routers
│   │   ├── config.py           # Pydantic settings (loads .env)
│   │   ├── database.py         # Supabase client initialization
│   │   ├── dependencies.py     # FastAPI dependency injection
│   │   ├── models/             # Pydantic request/response schemas
│   │   ├── routers/
│   │   │   ├── auth.py         # Auth endpoints (login, register, profile)
│   │   │   ├── events.py       # Campus events CRUD
│   │   │   └── chat.py         # AI chat endpoint (Gemini/Groq)
│   │   └── services/
│   │       ├── llm_service.py  # LLM integration (Gemini + Groq)
│   │       └── context_service.py  # Campus context for AI
│   ├── .env.example            # Environment variable template
│   └── requirements.txt        # Python dependencies
│
├── frontend/                   # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart           # App entry, Supabase init, theming
│   │   ├── models/             # Data models (User, Event, Chat)
│   │   ├── providers/          # Riverpod providers (auth state)
│   │   ├── screens/
│   │   │   ├── login_screen.dart   # Login & registration
│   │   │   ├── home_screen.dart    # Dashboard / home
│   │   │   ├── chat_screen.dart    # AI chat interface
│   │   │   ├── events_screen.dart  # Campus events listing
│   │   │   ├── profile_screen.dart # User profile
│   │   │   └── app_shell.dart      # Bottom navigation shell
│   │   ├── services/
│   │   │   ├── api_service.dart    # Backend API client (Dio)
│   │   │   ├── auth_service.dart   # Supabase auth wrapper
│   │   │   └── tts_service.dart    # Text-to-speech service
│   │   └── widgets/            # Reusable UI components
│   ├── .env.example            # Frontend env template
│   └── pubspec.yaml            # Flutter dependencies
│
├── supabase_migration.sql      # Database schema (tables, RLS, indexes)
├── seed_data.sql               # Sample events & FAQs
├── DEPLOYMENT.md               # Production deployment guide
└── .gitignore
```

---

## 📦 Prerequisites

Before you begin, make sure you have the following installed:

| Tool | Version | Download |
|------|---------|----------|
| **Flutter SDK** | 3.x+ | [flutter.dev/get-started](https://flutter.dev/docs/get-started/install) |
| **Python** | 3.11+ | [python.org](https://www.python.org/downloads/) |
| **Git** | Latest | [git-scm.com](https://git-scm.com/) |
| **Supabase Account** | Free tier | [supabase.com](https://supabase.com/) |
| **Gemini API Key** | Free tier | [aistudio.google.com](https://aistudio.google.com/app/apikey) |

---

## 🚀 Setup Guide

### 1. Supabase Setup

1. Create a free project at [supabase.com](https://supabase.com/).

2. Go to **SQL Editor** and run the migration script:
   ```sql
   -- Copy and paste the entire contents of supabase_migration.sql
   ```
   This creates 5 tables: `users`, `chat_sessions`, `chat_messages`, `campus_events`, `campus_faqs`.

3. **(Optional)** Seed with sample data:
   ```sql
   -- Copy and paste the entire contents of seed_data.sql
   ```

4. Note down your credentials from **Settings → API**:
   - **Project URL**: `https://xxxxxxxx.supabase.co`
   - **anon (public) key**: `eyJhbGci...`
   - **service_role key**: `eyJhbGci...`

---

### 2. Backend Setup

```bash
# Clone the repository
git clone https://github.com/atanupaul1/CampusAI.git
cd CampusAI/backend

# Create a virtual environment
python -m venv venv

# Activate it
# Windows:
.\venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create your .env file
cp .env.example .env
```

Edit `backend/.env` with your actual credentials:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-supabase-anon-key
SUPABASE_SERVICE_KEY=your-supabase-service-role-key
GEMINI_API_KEY=your-gemini-api-key
GROQ_API_KEY=your-groq-api-key          # optional
UNIVERSITY_NAME=Your University Name
APP_ENV=development
```

Start the backend:
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Verify it's running: open [http://localhost:8000/health](http://localhost:8000/health) — should return `{"status": "ok"}`.

> 📖 **API Docs**: Visit [http://localhost:8000/docs](http://localhost:8000/docs) for the interactive Swagger UI.

---

### 3. Frontend Setup

```bash
cd CampusAI/frontend

# Install Flutter dependencies
flutter pub get

# Create your .env file
cp .env.example .env
```

Edit `frontend/.env` with your credentials:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
API_BASE_URL=http://YOUR_COMPUTER_IP:8000
```

> 💡 **Finding your IP**: Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux) and use the IPv4 address under your WiFi adapter (e.g., `192.168.1.8`).

Run the app:
```bash
# Connect your phone via USB (with USB debugging enabled)
flutter run --dart-define-from-file=.env
```

Or build an APK:
```bash
flutter build apk --dart-define-from-file=.env
```

> ⚠️ **Important**: Your phone must be on the **same WiFi network** as your computer for the local backend connection to work.

---

## ▶️ Running the App

### Quick Start (2 terminals)

**Terminal 1 — Backend:**
```bash
cd backend
.\venv\Scripts\activate          # Windows
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
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
