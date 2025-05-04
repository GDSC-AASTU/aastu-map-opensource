# Welcome to the AASTU MAP Project 🗺️

## Description 📝
This Flutter project aims to provide a full virtual guide experience for visitors and students at Addis Ababa Science and Technology University. Developed by members of the Google Developer Students Club, the app includes detailed maps and features to enhance campus navigation.

## Steps to Contribute 🛠️

1. **Clone the Repository:**
   - Clone the project to your local machine.
   - Use the command `git clone https://github.com/GDSC-AASTU/aastu-map-opensource.git`.

2. **Set up API Keys:**
   - This project requires several API keys to function properly:
     - **Firebase**: Create a Firebase project and add your configuration
     - **Google Maps**: Get a Google Maps API key from Google Cloud Console
     - **OpenAI** (optional for chat feature): Get an API key from OpenAI
     - **Gebeta Maps**: Register for an API key at [Gebeta Maps](https://maps.gebeta.app)

3. **Replace Placeholder API Keys:**
   - Replace placeholder values in the following files:
     - `lib/firebase_options.dart`: Firebase API keys
     - `android/app/src/main/AndroidManifest.xml`: Google Maps API key
     - `lib/pages/chat/api_config.dart`: OpenAI API key
     - `lib/pages/discover/gebeta_maps_service.dart`: Gebeta Maps API key
     - `android/app/google-services.json`: Firebase configuration

4. **Run the Project:**
   - Navigate to the project directory.
   - Run `flutter pub get` to install dependencies.
   - Execute `flutter run` to start the app.

## Required Dependencies
- Flutter SDK (latest stable version)
- Firebase CLI (for Firebase setup)
- Android Studio / VS Code with Flutter extensions

## Troubleshooting
- If you encounter any build errors, make sure all API keys are properly set up
- For Android build issues, check that you have set the correct compileSdkVersion in android/app/build.gradle (recommended: 33 or higher)

## Commit and PR Rules 📜

1. **Descriptive Commits:**
   - Commit messages should be clear and descriptive.
   - Example: `[Fix] Signup form validation`.

2. **Branching:**
   - Always create your branch for new features or fixes.
   - Use the format: `yourname.feature_name`.
   - Example: `gemechis.signup_form_validation`.

3. **Rebase to Main:**
   - Rebase your branch to the main branch before creating a pull request.
   - Use `git pull --rebase origin main`.

## Happy Coding! 💻
