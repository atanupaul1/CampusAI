# Campus AI Assistant — Deployment Guide

## Backend Deployment (Render.com Free Tier)

### 1. Prepare the Repository

Make sure your repo has this structure:
```
backend/
├── app/
├── requirements.txt
└── .env  (do NOT commit this)
```

### 2. Create a Render Web Service

1. Go to [render.com](https://render.com) and sign in with GitHub.
2. Click **"New" → "Web Service"**.
3. Connect your GitHub repository.
4. Configure:
   - **Name**: `campus-ai-backend`
   - **Root Directory**: `backend`
   - **Runtime**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Plan**: Free

### 3. Set Environment Variables

In the Render dashboard → **Environment** tab, add:

| Key | Value |
|-----|-------|
| `SUPABASE_URL` | `https://your-project.supabase.co` |
| `SUPABASE_KEY` | Your Supabase anon key |
| `SUPABASE_SERVICE_KEY` | Your Supabase service role key |
| `GEMINI_API_KEY` | Your Gemini API key |
| `GROQ_API_KEY` | Your Groq API key (optional) |
| `UNIVERSITY_NAME` | Your University Name |

### 4. Deploy

Click **"Create Web Service"**. Render will build and deploy.
Verify: `https://campus-ai-backend.onrender.com/health` should return `{"status": "ok"}`.

> **Note:** Free tier spins down after 15 minutes of inactivity.
> First request after idle will take ~30 seconds.

---

## Local Development with Ngrok

For demos or Flutter development against your local backend:

```bash
# Terminal 1: Start the backend
cd backend
uvicorn app.main:app --reload --port 8000

# Terminal 2: Expose via Ngrok
ngrok http 8000
```

Use the Ngrok HTTPS URL as your Flutter app's `API_BASE_URL`:
```bash
flutter run --dart-define=API_BASE_URL=https://xxxx.ngrok-free.app \
            --dart-define=SUPABASE_URL=https://your-project.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=your-key
```

---

## Flutter App Build

### Debug APK (for testing)
```bash
cd frontend
flutter build apk --debug \
  --dart-define=API_BASE_URL=https://campus-ai-backend.onrender.com \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-key
```

### Release APK
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://campus-ai-backend.onrender.com \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-key
```

The APK will be at `frontend/build/app/outputs/flutter-apk/app-release.apk`.
