# 📝 iNotes - Mobile-First Note Management Backend

## 🔐 Authentication Endpoints

### 1. User Registration
- **Endpoint**: `POST /auth/register`
- **Postman Test Parameters**:
  ```json
  {
    "email": "user@example.com",
    "username": "johndoe",
    "password": "StrongPass123!"
  }
  ```
- **Validations**:
  - Email format check
  - Username requirements
  - Password complexity

### 2. User Login
- **Endpoint**: `POST /auth/login`
- **Postman Test Parameters**:
  ```json
  {
    "username": "johndoe",
    "password": "StrongPass123!"
  }
  ```

## 👤 User Management Endpoints

### 3. Get User Profile
- **Endpoint**: `GET /user`
- **Postman Query Parameters**:
  - `user_id`: Integer (Required)
  
### 4. Update Profile Picture
- **Endpoint**: `POST /update-profile-picture`
- **Postman Form-data Parameters**:
  - `user_id`: Integer
  - `avatar`: File upload

### 5. Delete Account
- **Endpoint**: `DELETE /delete-account`
- **Postman Query Parameters**:
  - `user_id`: Integer (Required)

## 📓 Note Management Endpoints

### 6. Create Note
- **Endpoint**: `POST /note`
- **Postman Form-data Parameters**:
  ```
  user_id: 1
  category_id: 2
  title: My First Note
  content: Note content here
  category: Personal
  delta: Optional rich text data
  color: 0xFF0000 (Hex color)
  ```

### 7. Fetch Notes
- **Endpoint**: `GET /notes`
- **Postman Query Parameters**:
  - `user_id`: Integer
  - `page`: Integer (Optional, default: 1)
  - `per_page`: Integer (Optional, default: 10)

### 8. Search Notes
- **Endpoint**: `POST /notes/{query}`
- **Postman Path Variable**:
  - `query`: Search term

### 9. Update Note
- **Endpoint**: `PUT /note`
- **Postman JSON Body**:
  ```json
  {
    "user_id": 1,
    "note_id": 5,
    "title": "Updated Note Title",
    "content": "Updated content",
    "delta": "Optional rich text update"
  }
  ```

## 🏷 Category Management

### 10. Create Category
- **Endpoint**: `POST /category`
- **Postman Form-data Parameters**:
  ```
  user_id: 1
  name: Work
  color: 0x2196F3
  avatar: (File upload)
  ```

### 11. Fetch Categories
- **Endpoint**: `GET /categories`
- **Postman Query Parameters**:
  - `user_id`: Integer

## 🛡 Security Features
- Input validation
- Regex-based email/username checks
- Secure password handling
- Connection pooling
- Comprehensive error management

## 📦 Development Setup

### Prerequisites
- Rust (latest stable version)
- MySQL
- Cargo

### Installation Steps
1. Clone repository
2. Configure `.env` file // DATABASE_URL = `your_database_url(path)`
3. Setup MySQL database
4. `cargo build`
5. `cargo run`

## 🔍 Performance Optimization
- Connection pooling
- Efficient database queries
- Async programming model

## 🤝 Contributing
1. Fork Repository
2. Create Feature Branch
3. Commit Changes
4. Push to Branch
5. Open Pull Request