# How to Install Flutter and Run Spendwise

## 1. Install Flutter (Recommended Method)
The most reliable way to install Flutter is using `git`. This avoids version errors.

1.  **Remove the previous broken installation** (if any):
    ```bash
    rm -rf ~/development/flutter
    ```

2.  **Clone the Flutter repository**:
    ```bash
    mkdir -p ~/development
    git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter
    ```

3.  **Add Flutter to your PATH**:
    (You might have already done this, but let's double check).
    - Open your shell configuration:
    ```bash
    nano ~/.zshrc
    ```
    - Ensure this line is at the end:
    ```bash
    export PATH="$PATH:$HOME/development/flutter/bin"
    ```
    - Save and exit (Ctrl+O, Enter, Ctrl+X).
    - Refresh your terminal:
    ```bash
    source ~/.zshrc
    ```

## 2. Verify Installation
Run the following command. It might take a minute to download the Dart SDK the first time.
```bash
flutter doctor
```

## 3. Run the App
1.  Navigate to the project folder:
    ```bash
    cd /Users/taatimannem/Documents/AICode/spendwise_mobile
    ```
2.  Get dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run
    ```
