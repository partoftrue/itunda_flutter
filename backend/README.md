# Finance App Backend

This is the Spring Boot backend for the Finance App, focusing on the neighborhood community feature (동네생활).

## Features

- JWT Authentication (Login/Register)
- Neighborhood Posts CRUD operations
- Comments on posts
- Likes for posts and comments
- Categories for posts

## Tech Stack

- Kotlin
- Spring Boot 3.2.1
- Spring Security with JWT
- Spring Data JPA
- H2 Database (for development)
- Gradle

## Running the Application

### Prerequisites

- JDK 17 or higher
- Gradle 7.6 or higher

### Build and Run

```bash
# Clone the repository
git clone https://your-repository-url.git
cd finance-app-backend

# Build the application
./gradlew build

# Run the application
./gradlew bootRun
```

The application will start on port 8080 with context path `/api/v1`.

## API Endpoints

### Authentication

- POST `/api/v1/auth/register` - Register a new user
- POST `/api/v1/auth/login` - Login user
- GET `/api/v1/auth/profile` - Get current user profile (requires authentication)

### Neighborhood

- GET `/api/v1/posts` - Get all posts (with pagination, category filter)
- GET `/api/v1/posts/popular` - Get popular posts
- GET `/api/v1/posts/{postId}` - Get a specific post
- POST `/api/v1/posts` - Create a new post (requires authentication)
- PUT `/api/v1/posts/{postId}` - Update a post (requires authentication)
- DELETE `/api/v1/posts/{postId}` - Delete a post (requires authentication)
- POST `/api/v1/posts/{postId}/like` - Like/unlike a post (requires authentication)

- GET `/api/v1/comments/post/{postId}` - Get comments for a post
- POST `/api/v1/comments` - Create a new comment (requires authentication)
- PUT `/api/v1/comments/{commentId}` - Update a comment (requires authentication)
- DELETE `/api/v1/comments/{commentId}` - Delete a comment (requires authentication)
- POST `/api/v1/comments/{commentId}/like` - Like/unlike a comment (requires authentication)

- GET `/api/v1/categories` - Get all categories

## Development

### Database

The application uses an H2 in-memory database for development. The H2 console is available at `/api/v1/h2-console`.

Database credentials (for development):
- URL: `jdbc:h2:mem:financeapp`
- Username: `sa`
- Password: `password`

### Sample Data

The application is pre-loaded with sample data including:
- A test user (email: `user@example.com`, password: `password`)
- Sample categories (동네질문, 동네소식, etc.)
- Sample posts and comments

## Mobile App Integration

This backend is designed to work with the Flutter-based mobile app. To connect:

1. The mobile app uses `http://10.0.2.2:8080/api/v1` to connect to the backend when running on an Android emulator
2. For iOS simulator, use `http://localhost:8080/api/v1` instead
3. For physical devices, use your machine's IP address or deploy the backend to a public server

## License

This project is licensed under the MIT License - see the LICENSE file for details. 