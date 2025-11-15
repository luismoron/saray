# Bazar de Saray

A Flutter-based e-commerce app for selling spare parts for various household appliances and more. Built with Firebase for authentication, database, and storage services.

## Features

- **User Authentication**: Secure login and registration using Firebase Auth.
- **Product Catalog**: Browse and search for spare parts and appliances.
- **Shopping Cart**: Add items to cart, manage quantities, and proceed to checkout.
- **Order Management**: Place orders and track status.
- **Admin Panel**: For managing products and orders (future feature).
- **Cross-Platform**: Runs on Android, iOS, and Web.

## Technologies Used

- **Flutter**: UI framework for building natively compiled applications.
- **Firebase**:
  - Auth: User authentication.
  - Firestore: NoSQL database for products, users, and orders.
  - Storage: For product images.
  - Cloud Messaging: Push notifications (planned).

## Getting Started

### Prerequisites

- Flutter SDK (version 3.10.0 or higher)
- Dart SDK
- Firebase account and project setup

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/bazar.git
   cd bazar
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Firebase:
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
   - Add Android/iOS/Web apps and download config files (google-services.json, GoogleService-Info.plist).
   - Place config files in the appropriate directories (android/app/, ios/Runner/, web/).

4. Run the app:
   ```bash
   flutter run
   ```

### Project Structure

- `lib/`: Main application code.
  - `models/`: Data models (User, Product, Order).
  - `screens/`: UI screens (Login, Home, Cart, etc.).
  - `services/`: Firebase services and business logic.
  - `widgets/`: Reusable UI components.
- `docs/`: Project documentation (tasks, rules, logic).
- `test/`: Unit tests.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions or support, contact [your email or contact info].
