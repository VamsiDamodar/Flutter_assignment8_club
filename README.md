# Hotspot Host Onboarding Questionnaire

**Flutter Internship Assignment – 8Club**

A pixel-perfect, responsive onboarding flow for Hotspot Hosts with API integration, multi-selection, text limits, audio/video recording, and smooth animations.

---

## Features Implemented (Core Requirements)

### 1. Experience Type Selection Screen
- Fetches experiences from `GET https://staging.chamberofsecrets.8club.co/v1/experiences?active=true` using **Http**
- Displays stamp-style cards using `image_url` as background
- **Multi-selection** supported (tap to select/deselect)
- Unselected cards show **grayscale** filter, selected cards in full color
- **250-character limit** multi-line text field ("Describe your perfect hotspot")
- Clean UI with proper spacing and modern stamp design
- Stores selected experience IDs and description text in state
- On "Next" → logs state to console and navigates to Onboarding Question Screen

### 2. Onboarding Question Screen
- **600-character limit** multi-line text field
- **Audio recording** with live waveform visualization
- **Video recording** using device camera
- **Dynamic layout**: Audio/Video record buttons **automatically disappear** from bottom when asset is recorded
- Option to **delete** recorded audio or video
- Option to **cancel** recording in progress
- Responsive layout adjusts when keyboard is open

---

## Brownie Points Implemented

### UI/UX
- **Pixel-perfect design** matching Figma (fonts, colors, spacings, corner radius, shadows)



### API & Networking
- **http** used for API calls with loading and error states

### Animations
- **Question Screen**: "Next" button **animates width** smoothly when record buttons disappear

---
## Additional Features & Polish
- Haptic feedback on card selection
- Proper disposal of recorders and video controllers
- Clean, scalable folder structure (`screens/`, `widgets/`, `providers/`, `models/`, `services/`)

---

## Tech Stack
- Flutter 3.19+
- Dart
- cached_network_image
- flutter_audio_recorder2 (Audio + Waveform)
- image_picker + video_player (Video)
- path_provider

---

## Project Structure