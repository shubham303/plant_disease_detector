# Plant Disease Detector App

A Flutter mobile application that helps users identify plant diseases by taking photos and sending them to a backend service for analysis.

## Features

- **Camera Integration**: Take photos directly from the app or select from gallery
- **Image Analysis**: Send images to backend service for plant disease identification
- **Markdown Display**: View detailed analysis results in formatted markdown
- **User-Friendly UI**: Clean, intuitive interface with loading states and error handling
- **Google Sign-In**: Secure authentication using Google accounts for personalized experience
- **Payment Subscription Integration**: Premium subscription plans with integrated payment processing

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development
- A backend service that accepts image analysis requests

### Installation

1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd plant_disease_detector
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure the backend URL:
   - Open `lib/services/plant_analysis_service.dart`
   - Replace `YOUR_BACKEND_URL_HERE` with your actual backend service URL

### Backend API Requirements

Your backend service should accept POST requests with the following format:

**Endpoint**: `POST /analyze`

**Request Headers**:
```json
{
  "Content-Type": "application/json",
  "Accept": "application/json"
}
```

**Request Body**:
```json
{
  "image": "base64_encoded_image_string",
  "format": "base64"
}
```

**Response Format**:
```json
{
  "analysis": "# Plant Analysis Result\n\n## Plant Information\n- **Species**: Tomato Plant\n- **Health Status**: Disease Detected\n\n## Disease Details\n- **Disease Name**: Early Blight\n- **Severity**: Moderate\n- **Description**: Early blight is a common fungal disease...\n\n## Treatment Recommendations\n1. Remove affected leaves immediately\n2. Apply fungicide spray\n3. Improve air circulation around plants"
}
```

The `analysis` field should contain markdown-formatted text with plant information, disease details, and treatment recommendations.

### Running the App

1. Connect your device or start an emulator
2. Run the app:
   ```bash
   flutter run
   ```

### Platform Permissions

The app requires camera and photo library permissions:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos of plants for disease analysis.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select plant images for disease analysis.</string>
```

## App Structure

```
lib/
├── main.dart                    # Main app entry point and UI
├── services/
│   └── plant_analysis_service.dart  # Backend API service
```

## Dependencies

- `camera: ^0.10.6` - Camera functionality
- `image_picker: ^1.1.2` - Image selection from gallery
- `http: ^1.2.2` - HTTP requests to backend
- `flutter_markdown: ^0.7.3` - Markdown rendering
- `path_provider: ^2.1.4` - File path management

## Usage

1. **Take or Select Photo**: Use the camera button to take a new photo or gallery button to select an existing image
2. **Analyze Plant**: Tap the "Analyze Plant" button to send the image to your backend service
3. **View Results**: The analysis results will be displayed in markdown format below the image
4. **Reset**: Use the refresh button in the app bar to start over with a new image

## Error Handling

The app includes comprehensive error handling for:
- Camera/gallery access issues
- Network connectivity problems
- Backend service errors
- Invalid responses

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.# plant_disease_detector
