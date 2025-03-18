# iRescue: Disaster Management Mobile Application

## 🌍 Project Overview

iRescue is a comprehensive disaster management mobile application developed during a hackathon, designed to provide critical support during emergency situations. The app focuses on resource management, emergency alerts, and SOS functionality to help communities respond effectively to disasters.

## 🚀 Key Features

### 1. Emergency Alert System
- Real-time alerts for various disaster types (Earthquake, Flood, Fire, etc.)
- Severity-based notification system
- Geolocation-based alert filtering

### 2. Resource Management
- Centralized warehouse inventory tracking
- Resource allocation and transfer
- Low stock alerts and capacity monitoring

### 3. SOS Functionality
- One-tap emergency request
- Location sharing
- Photo upload for emergency context
- Multiple emergency types support

### 4. User Roles
- Civilian Users
  - Submit SOS requests
  - View alerts
  - Access emergency resources
- Admin/Government Users
  - Manage warehouses
  - Create and manage alerts
  - Coordinate resource allocation

## 🛠 Technical Architecture

### State Management
- Implemented using Flutter BLoC (Business Logic Component)
- Separation of concerns with event-driven architecture

### Key Services
- Authentication Service
- Database Service
- Location Service
- Connectivity Service
- Offline Queue Management

### Mock Services
The app uses mock services for hackathon demonstration, simulating:
- User authentication
- Database interactions
- Location tracking
- Connectivity states

## 🔧 Demo Controls

Special demo controls allow quick simulation of:
- Connectivity states (Online/Offline)
- Location changes
- Service resets

## 🖥 Screens

1. Authentication
   - Login
   - Registration

2. Civilian Dashboard
   - Active Alerts
   - SOS Button
   - Emergency Resources
   - Profile Management

3. Admin Dashboard
   - Warehouse Management
   - Resource Allocation
   - Alert Creation
   - User Management

## 📱 UI/UX Highlights
- Responsive design
- Dark/Light theme support
- Intuitive navigation
- Emergency-focused color schemes

## 🚦 Demo Credentials

### Admin Access
- Email: admin@test.com
- Password: password

### Civilian Access
- Email: user@test.com
- Password: password

## 🛡️ Offline Capabilities
- Offline queue management
- Sync operations when connectivity restored
- Graceful error handling



## 🔮 Potential Future Enhancements
- Integration with real geolocation services
- Advanced notification systems
- Machine learning for predictive disaster management
- Multilingual support
- Comprehensive user verification

## 📦 Tech Stack
- Flutter
- Dart
- BLoC State Management
- Firebase (Mock for Demo)
- Connectivity Plus
- Geolocator



## 👥 Contributor
Developed by Gautam kumar 