# SpendAI - Smart Expense Tracker

A modern Flutter expense tracking application with AI-powered analysis and OCR receipt scanning.

## Features

### 📸 Receipt Scanning
- **On-device OCR** using Google ML Kit
- Automatic extraction of merchant, amount, and date
- Review and confirm before saving
- Direct card selection in the scan dialog

### 💳 Card Management
- Add and manage multiple credit cards
- Link transactions to specific cards
- Visual card representation with custom colors

### 🤖 AI Analysis
- Chat with Gemini AI about your spending
- Ask questions like "How much did I spend on food?"
- Powered by Google's Gemini 2.0 Flash model

### 📊 Dashboard
- Interactive pie chart showing spending by category
- Recent transactions list
- Total balance overview

### ✍️ Manual Entry
- Quick manual transaction entry
- Support for both expenses and income
- Category selection
- Date picker

## Tech Stack

- **Framework**: Flutter
- **State Management**: Provider
- **AI**: Google Generative AI (Gemini)
- **OCR**: Google ML Kit Text Recognition
- **Charts**: FL Chart
- **Storage**: SharedPreferences

## Setup

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Google Gemini API Key

### Installation

1. Clone the repository:
```bash
git clone https://github.com/priyadharshanr31/ExpenseTracker.git
cd ExpenseTracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create a `.env` file in the root directory:
```env
GEMINI_API_KEY=your_api_key_here
GEMINI_MODEL=gemini-2.0-flash-exp
```

4. Run the app:
```bash
flutter run
```

## Configuration

### API Keys
Get your Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)

### Permissions
The app requires the following permissions (already configured):
- Camera access (for receipt scanning)
- Storage access (for gallery selection)
- Internet (for AI features)

## Usage

### Scanning Receipts
1. Go to **Add** → **Scan Receipt**
2. Choose **Camera** or **Gallery**
3. Review the extracted details
4. Select the card used
5. Click **Save Transaction**

### Manual Entry
1. Go to **Add** → **Manual Entry**
2. Fill in the transaction details
3. Select card (for expenses)
4. Click **Save Transaction**

### AI Analysis
1. Go to **AI Analysis** tab
2. Ask questions about your spending
3. Get insights powered by Gemini AI

## Project Structure

```
lib/
├── models/
│   ├── transaction.dart
│   └── card_model.dart
├── providers/
│   ├── transaction_provider.dart
│   └── card_provider.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── add_screen.dart
│   ├── cards_screen.dart
│   └── ai_screen.dart
└── main.dart
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  fl_chart: ^0.65.0
  google_fonts: ^6.1.0
  image_picker: ^1.2.1
  google_mlkit_text_recognition: ^0.15.0
  permission_handler: ^12.0.1
  provider: ^6.1.1
  flutter_dotenv: ^5.1.0
  google_generative_ai: ^0.4.0
  uuid: ^4.2.1
  intl: ^0.19.0
  shared_preferences: ^2.2.2
```

## Features in Detail

### Dark Theme
- Premium dark color scheme
- Optimized for OLED displays
- Consistent theming across all screens

### Data Persistence
- Automatic saving of transactions
- Card data persistence
- Survives app restarts

### Smart OCR
- Regex-based parsing for accuracy
- Handles multiple date formats
- Finds the largest amount (usually the total)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Author

Priyadharshan R

## Acknowledgments

- Google ML Kit for OCR
- Google Gemini for AI capabilities
- Flutter team for the amazing framework
