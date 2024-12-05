# 📝 iNotes - Mobile-First Note Management Backend

## 🔐 Authentication Endpoints

### $${\color{green}1.\space User \space Registration}$$

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

### $${\color{green} 2.\space User \space Login}$$
- **$${\color{orange} Endpoint}$$**: `POST /auth/login`
- **$${\color{orange} Postman \space Test \space Parameters}$$**:
  ```json
  {
    "username": "johndoe",
    "password": "StrongPass123!"
  }
  ```

## 👤 User Management Endpoints

### $${\color{green} 3.\space Get \space User \space Profile}$$
- **$${\color{orange} Endpoint}$$**: `GET /user`
- **$${\color{orange} Postman \space Query \space Parameters}$$**:
  - `user_id`: Integer (Required)
  
### $${\color{green} 4.\space Update \space Profile \space Picture}$$
- **$${\color{orange} Endpoint}$$**: `POST /update-profile-picture`
- **$${\color{orange} Postman \space Form-data \space Parameters}$$**:
  - `user_id`: Integer
  - `avatar`: File upload

### $${\color{green} 5.\space Delete \space Account}$$
- **$${\color{orange} Endpoint}$$**: `DELETE /delete-account`
- **$${\color{orange} Postman \space Query \space Parameters}$$**:
  - `user_id`: Integer (Required)

## 📓 Note Management Endpoints

### $${\color{green} 6.\space Create \space Note}$$
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
### $${\color{green} 7.\space Fetch \space Recent \space Notes:}$$
- **$${\color{orange} Endpoint}$$**: `GET /recent-notes`
- **$${\color{orange} Postman \space Query \space Parameters}$$**:
  ```
  user_id: Integer (Required)
  ```

### $${\color{green} 8.\space Search \space Notes}$$
- **$${\color{orange} Endpoint}$$**: `POST /notes/{query}`
- **$${\color{orange} Postman \space Path \space Variable}$$**:
  - `query`: Search term

### $${\color{green} 9.\space Update \space Note}$$
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

### $${\color{green} 10.\space Delete \space Note:}$$
- **$${\color{orange} Endpoint}$$**: `DELETE /note`
- **$${\color{orange} Postman \space Query \space Parameters}$$**:
  ```
  user_id: Integer (Required)
  note_id: Integer (Required)
  category_id: Integer (Required)
  ```
  
### $${\color{green} 11.\space Fetch \space Notes \space by \space Category:}$$
- **$${\color{orange} Endpoint}$$**: `GET /notes-by-category`
- **$${\color{orange} Postman \space Query \space Parameters}$$**:
  ```
  user_id: Integer (Required)
  category_id: Integer (Required)
  page: Integer (Optional, default: 1)
  per_page: Integer (Optional, default: 10)
  ```

## 🏷 Category Management

### $${\color{green} 12.\space Create \space Category}$$
- **$${\color{orange} Endpoint}$$**: `POST /category`
- **$${\color{orange} Postman \space Form-data \space Parameters}$$**:
  ```
  user_id: 1
  name: Work
  color: 0x2196F3
  avatar: (File upload)
  ```
  
### $${\color{green} 13.\space Delete \space Category}$$
- **$${\color{orange} Endpoint}$$**: `DELETE /category/delete`
- **$${\color{orange} Postman \space Query \space Parameters}$$**:
  ```
  user_id: Integer (Required)
  category_id: Integer (Required)
  ```

### $${\color{green} 14.\space Fetch \space Categories}$$
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
2. Configure `.env` file (DATABASE_URL = `your_database_url(path)`)
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
