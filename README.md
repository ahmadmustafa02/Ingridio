# 🍳 Ingridio
### *Stop wondering what to cook. Just snap your fridge.*

<div align="center">

<img width="1408" height="768" alt="Gemini_Generated_Image_gkk2lagkk2lagkk2" src="https://github.com/user-attachments/assets/80e94e6e-7e7e-4c29-b71c-233ab7b8dc5f" />


[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Gemini AI](https://img.shields.io/badge/Gemini_2.0_Flash-AI_Powered-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev)
[![Cloud Run](https://img.shields.io/badge/Google_Cloud_Run-Deployed-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com/run)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**[🌐 Live Demo](https://ingridio-378480318821.europe-west1.run.app/) · [📱 Download APK](#) · [🎥 Watch Demo](#)**

*Submitted for Google Cloud AI Seekho 2026 🇵🇰*
*#AISeekho2026 #VibeKaregaPakistan*

</div>

---

## ✨ What is Ingridio?

Ingridio is an **AI-powered recipe assistant** that transforms the way you cook. Point your camera at whatever ingredients you have in your fridge or kitchen — Ingridio's AI instantly identifies every food item and generates personalized, step-by-step recipes you can make **right now**, with what you already have.

No more wasted groceries. No more staring at a full fridge wondering what to eat.

---

## 🎯 The Problem We Solve

> Every day, millions of people throw away perfectly good food simply because they don't know what to make with it. Globally, 1/3 of all food produced is wasted.

Ingridio eliminates this by turning **"I have nothing to eat"** into **"I can make 3 amazing dishes right now."**

---

## 🚀 How It Works

```
📸 SNAP  →  🧠 DETECT  →  🍽️ COOK
```

| Step | What Happens |
|------|-------------|
| 1️⃣ **Snap** | Take a photo of your fridge, kitchen counter, or any ingredients |
| 2️⃣ **Detect** | Gemini 2.0 Flash Vision AI identifies every ingredient instantly |
| 3️⃣ **Match** | Get 3 personalized recipes based on your dietary preferences |
| 4️⃣ **Cook** | Follow guided step-by-step cooking mode with built-in timers |

---

## 📸 Screenshots

<div align="center">

| Onboarding | Scan | Results | Recipe |
|-----------|------|---------|--------|
| <img src="https://github.com/user-attachments/assets/2e9f7d31-bd3f-45c8-9eca-1e921dfbe968" width="180"/> | <img src="https://github.com/user-attachments/assets/d098480c-7f6e-4cd8-8fdd-adf4c6d698ab" width="180"/> | <img src="https://github.com/user-attachments/assets/eba105fe-98b2-4b40-aa95-af3f5545764d" width="180"/> | <img src="https://github.com/user-attachments/assets/d3d7d249-9bf8-4e64-891b-67d1cd4c34a5" width="180"/> |

</div>

---

## ⚡ Features

- 📸 **Real-time AI Ingredient Detection** — Point at any food, Gemini sees everything
- 🍜 **Cuisine-Aware Recipes** — Tailored to your preferred cuisine style
- 🥗 **Dietary Preference Filtering** — Vegan, halal, gluten-free and more
- 👨‍🍳 **Guided Cooking Mode** — Step-by-step instructions with timers
- 🌍 **Bilingual Support** — English & Urdu recipe output
- 💚 **Reduce Food Waste** — Cook with what you already have
- 🖼️ **Gallery Support** — Use existing photos from your camera roll
- ⚡ **Instant Results** — No waiting, no searching, no guessing

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| 📱 **Frontend** | Flutter & Dart |
| 🧠 **AI Vision** | Google Gemini 2.0 Flash API |
| ☁️ **Deployment** | Google Cloud Run |
| 🔧 **AI Studio** | Google AI Studio |
| 🐳 **Container** | Docker + Nginx |
| 🔐 **Config** | flutter_dotenv |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│              Flutter App (Dart)              │
│                                             │
│  📸 Camera/Gallery → GeminiService          │
│         ↓                                   │
│  🧠 Gemini 2.0 Flash Vision API             │
│         ↓                                   │
│  🍽️ Recipe Generation + Mapping             │
│         ↓                                   │
│  📱 Beautiful UI (Scan → Match → Cook)      │
└─────────────────────────────────────────────┘
         ↓ Flutter Build Web
┌─────────────────────────────────────────────┐
│         Google Cloud Run (Docker)            │
│         https://ingridio-378480318821        │
│              .europe-west1.run.app           │
└─────────────────────────────────────────────┘
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x+
- Dart 3.x+
- Google AI Studio API Key ([Get one free](https://aistudio.google.com/apikey))

### Installation

```bash
# Clone the repository
git clone https://github.com/ahmadmustafa02/Ingridio.git
cd Ingridio

# Install dependencies
flutter pub get

# Create environment file
echo "GEMINI_API_KEY=your_api_key_here" > assets/.env

# Run the app
flutter run
```

### Build for Web
```bash
flutter build web --release
```

### Deploy to Cloud Run
```bash
# Build and deploy using Docker
docker build -t ingridio .
gcloud run deploy ingridio --source .
```

---

## 🌐 Live Demo

Try Ingridio right now in your browser:

**[🔗 https://ingridio-378480318821.europe-west1.run.app/](https://ingridio-378480318821.europe-west1.run.app/)**

> 💡 **Tip:** Use "Continue as Guest" to explore without signing up. For the full AI scanning experience, run the Android app locally.

---

## 📁 Project Structure

```
lib/
├── data/           # Mock data & constants
├── logic/          # Business logic & state management
├── models/         # Data models (Recipe, Ingredient, etc.)
├── screens/        # All UI screens
│   ├── scan_screen.dart          # Camera + AI scan
│   ├── scan_result_screen.dart   # Detected ingredients
│   ├── recipe_match_screen.dart  # AI recipe matches
│   └── recipe_detail_screen.dart # Step-by-step cooking
├── services/
│   ├── gemini_service.dart       # Gemini AI integration
│   └── food_detection_service.dart
└── widgets/        # Reusable UI components
```

---

## 🏆 Submitted For

<div align="center">

**Google Cloud AI Seekho 2026** 🇵🇰

*Track: App Banaao — Building Impactful AI Solutions*

[![#AISeekho2026](https://img.shields.io/badge/%23AISeekho2026-Google_Cloud-4285F4?style=for-the-badge&logo=google&logoColor=white)](#)
[![#VibeKaregaPakistan](https://img.shields.io/badge/%23VibeKaregaPakistan-🇵🇰-00A651?style=for-the-badge)](#)

</div>

---

## 👨‍💻 Developer

**Ahmad Mustafa**

[![GitHub](https://img.shields.io/badge/GitHub-ahmadmustafa02-181717?style=for-the-badge&logo=github)](https://github.com/ahmadmustafa02)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

*Built with ❤️ in Pakistan 🇵🇰 using Google AI Studio & Cloud Run*

**#VibeKaregaPakistan 🚀**

</div>
