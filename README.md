<div align="center">

# 🎓 Campus AI

**An AI-powered campus companion app**

Ask about events, schedules, campus information, and more through an intelligent chat interface.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi)
![Supabase](https://img.shields.io/badge/Supabase-Database%20%26%20Auth-3ECF8E?logo=supabase)

</div>

---

## ✨ Features

* 🤖 **AI Chat** – Ask campus-related questions using Gemini / Groq LLM
* 🎤 **Voice Input** – Speech-to-text queries
* 📅 **Event Manager** – Students browse events, admins manage them
* ❓ **FAQ Builder** – Admins manage the AI knowledge base
* 💬 **Chat History** – Conversations stored in Supabase
* 🔐 **Admin Portal** – Secure access for campus staff
* 🌗 **Dark Mode** – Material 3 adaptive UI

---

## 🏗 Architecture

```
Student App (Flutter)
        │
        ▼
FastAPI Backend (Python)
        │
        ▼
Supabase (Database + Auth)

Admin App (Flutter)
        │
        └──── Manage Events & FAQs
```

---

## 🧰 Tech Stack

* **Frontend:** Flutter
* **Backend:** FastAPI
* **Database & Auth:** Supabase
* **AI Models:** Gemini / Groq
* **Deployment:** Render

---

## 📁 Project Structure

```
frontend/        → Student mobile app
admin_app/       → Admin management app
backend/         → FastAPI server
supabase_migration.sql
admin_setup.sql
```

---

## 🚀 Quick Setup

### 1️⃣ Supabase Setup

Run the SQL files inside Supabase SQL Editor:

```
supabase_migration.sql
admin_setup.sql
```

Promote your account to admin:

```sql
UPDATE public.users
SET role = 'admin'
WHERE email = 'YOUR_EMAIL';
```

---

### 2️⃣ Backend Setup

```
pip install -r requirements.txt
uvicorn app.main:app --reload
```

---

### 3️⃣ Student App

```
cd frontend
flutter run --dart-define-from-file=.env
```

---

### 4️⃣ Admin App

```
cd admin_app
flutter run --dart-define-from-file=.env
```

---

## 🌐 Deployment

* **Backend:** Render
* **Database:** Supabase

Build release APK:

```
flutter build apk --release --dart-define-from-file=.env
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a new branch
3. Commit your changes
4. Push the branch
5. Open a Pull Request

---

<div align="center">

Built with ❤️ at **ICFAI University, Tripura**

</div>
