# 📝 iNotes - Mobile-First Note Management Backend

## 🔐 Authentication Endpoints

### $${\color{green} 🔐 1. User \space Registration}$$

- **$${\color{orange} Endpoint}$$**: `POST /auth/register`
- **$${\color{orange} Postman \space Test \space Parameters}$$**:
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

### $${\color{green} 2. User \space Login}$$
- **$${\color{orange} Endpoint}$$**: `POST /auth/login`
- **$${\color{orange} Postman \space Test \space Parameters}$$**:
  ```json
  {
    "username": "johndoe",
    "password": "StrongPass123!"
  }
  ```

## 👤 User Management Endpoints

### $${\color{green} 3. Get \space User \space Profile}$$
- **$${\color{orange} Endpoint}$$**: `GET /user`
- **$${\color{orange} Postman \space Query \space Parameters}$$**:
  - `user_id`: Integer (Required)
  
### $${\color{green} 4. Update \space Profile \space Picture}$$
- **$${\color{orange} Endpoint}$$**: `POST /update-profile-picture`
- **$${\color{orange} Postman \space Form-data \space Parameters}$$**:
  - `user_id`: Integer
  - `avatar`: File upload

### $${\color{green} 5. Delete \space Account}$$
- **$${\color{orange} Endpoint}$$**: `DELETE /delete-account`
- **$${\color{orange} Postman \space Query \space Parameters}$$**:
  - `user_id`: Integer (Required)

## 📓 Note Management Endpoints

### $${\color{green} 6. Create \space Note}$$
- **$${\color{orange} Endpoint}$$**: `POST /note`
- **$${\color{orange} Postman \space Form-data \space Parameters}$$**:
  ```
  user_id: 1
  category_id: 2
  title: My First Note
  content: Note content here
  category: Personal
  delta: Optional rich text data
  color: 0xFF0000 (Hex color)
  ```

### $${\color{green} 7. Fetch \space Notes}$$
- **$${\color{orange} Endpoint}$$**: `GET /notes`
- **$${\color{orange} Postman \space Query \space Parameters}$$**:
  - `user_id`: Integer
  - `page`: Integer (Optional, default: 1)
  - `per_page`: Integer (Optional, default: 10)

### $${\color{green} 8. Search \space Notes}$$
- **$${\color{orange} Endpoint}$$**: `POST /notes/{query}`
- **$${\color{orange} Postman \space Path \space Variable}$$**:
  - `query`: Search term

### $${\color{green} 9. Update \space Note}$$
- **$${\color{orange} Endpoint}$$**: `PUT /note`
- **$${\color{orange} Postman \space JSON \space Body}$$**:
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

### $${\color{green} 10. Create \space Category}$$
- **$${\color{orange} Endpoint}$$**: `POST /category`
- **$${\color{orange} Postman \space Form-data \space Parameters}$$**:
  ```
  user_id: 1
  name: Work
  color: 0x2196F3
  avatar: (File upload)
  ```

### $${\color{green} 11. Fetch \space Categories}$$
- **$${\color{orange} Endpoint}$$**: `GET /categories`
- **$${\color{orange} Postman \space Query \space Parameters}$$**:
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
