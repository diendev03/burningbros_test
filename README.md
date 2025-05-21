# BurningBros - Product List with Infinite Scroll and Search

---

This Flutter application showcases a product list with features like infinite scrolling, product search with debouncing, and local favoritism.

---

## Setup

To get started with the project, follow these steps:

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/username/burningbros.git
    cd burningbros
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Generate model code:**

    This project uses `freezed` and `json_serializable` for model generation. Run the following command to generate the necessary files:

    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

---

## Run the App

### Debug Mode:

To run the app in debug mode, simply execute:

```bash
flutter run
```

### Build Release APK:

To build a release APK for Android, use the following command:

```bash
flutter build apk --release
```

---

## Features

* **Infinite Scroll:** Scroll to the bottom of the product list to automatically load more items.
* **Search:** Type a product name into the search bar. The results will update dynamically with a debounce mechanism for efficient searching.
* **Favorite:** Tap the heart icon on any product to mark it as a favorite or unfavorite it. This data is saved locally on your device.

---

## Notes

* An internet connection is required to fetch product data.
* The application handles various error states, including no data, failed loading, no network connection, and reaching the end of the product list.