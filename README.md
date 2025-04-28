# Finance Application API

A modern financial management application API built with NestJS, TypeORM, and MongoDB.

## Features

- User authentication and authorization with JWT
- Multi-database architecture (MySQL, MongoDB, Redis)
- Message broker integration with Kafka
- Role-based access control
- Financial transaction management
- User profile and preferences
- API documentation with Swagger

## Tech Stack

- **Backend Framework**: NestJS
- **Databases**:
  - MySQL (via TypeORM) - Core data storage
  - MongoDB (via Mongoose) - User profiles and reports
  - Redis - Caching and user preferences
- **Message Broker**: Kafka
- **Authentication**: JWT, Passport
- **Documentation**: Swagger/OpenAPI

## Getting Started

### Prerequisites

- Node.js (v14+)
- MySQL
- MongoDB
- Redis
- Kafka

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/finance-app.git
   cd finance-app
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure environment variables:
   - Create a `.env` file in the root directory based on the `.env.example` file
   - Update the database connection details and other configuration as needed

4. Run database migrations:
   ```bash
   npm run typeorm:run-migrations
   ```

5. Start the development server:
   ```bash
   npm run start:dev
   ```

6. Access the API at `http://localhost:3000`
7. Access the Swagger documentation at `http://localhost:3000/api/docs`

## Project Structure

```
src/
├── auth/                # Authentication related files
├── config/              # Configuration files
├── users/               # User module
├── transactions/        # Transactions module
├── notifications/       # Notifications module
├── app.module.ts        # Main application module
└── main.ts              # Application entry point
```

## API Endpoints

- **Auth**:
  - `POST /auth/login` - Login with email and password
  - `POST /auth/register` - Register new user
  - `GET /auth/profile` - Get authenticated user profile

- **Users**:
  - `GET /users` - Get all users (admin only)
  - `GET /users/:id` - Get user by ID
  - `PATCH /users/:id` - Update user
  - `DELETE /users/:id` - Delete user (admin only)
  - `GET /users/:id/profile` - Get user profile
  - `PATCH /users/:id/profile` - Update user profile

- **Transactions**:
  - `GET /transactions` - Get user transactions
  - `POST /transactions` - Create new transaction
  - `GET /transactions/:id` - Get transaction by ID
  - `PATCH /transactions/:id` - Update transaction
  - `DELETE /transactions/:id` - Delete transaction

## License

This project is licensed under the MIT License.
