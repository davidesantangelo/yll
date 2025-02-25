# YLL - Your Link Shortener

[![Ruby](https://img.shields.io/badge/Ruby-3.4.0-red)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-7.0.0-red)](https://rubyonrails.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

YLL is a powerful, lightweight URL shortener built with Ruby on Rails. Create and manage shortened URLs with advanced features like expiration dates and password protection.

## 🚀 Features

- **Short Links**: Generate unique 8-character codes for any URL
- **Expiration Control**: Set optional expiration times for temporary links
- **Security**: Password-protect links with HTTP Basic Authentication
- **Analytics**: Track clicks for each shortened URL
- **API Support**: Full JSON API for programmatic access

## 📋 Requirements

- Ruby 3.0+
- Rails 7.0+
- PostgreSQL (recommended)

## 🛠️ Installation

```bash
# Clone the repository
git clone https://github.com/davidesantangelo/yll.git

# Navigate to the project directory
cd yll

# Install dependencies
bundle install

# Set up the database
rails db:create
rails db:migrate

# Start the server
rails server
```

## 📝 Configuration

Create a `.env` file in the root directory with the following variables:

```
DATABASE_URL=postgres://username:password@localhost/yll_development
HOST_URL=http://localhost:3000
```

## 🔍 Usage

### Creating a Shortened URL

#### Via Web Interface
Visit `http://localhost:3000` and use the web form to create a new shortened link.

#### Via API
```bash
curl -X POST "http://localhost:3000/api/v1/links" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "password": "optional_password",
    "expires_at": "2025-12-31T23:59:59Z"
  }'
```

### Accessing a Shortened URL

Simply visit the generated short URL:
```
http://localhost:3000/r/{code}
```

### Using Password-Protected Links

When a link is password-protected, the browser will prompt for credentials:
- **Username**: The short code
- **Password**: The password you set when creating the link

Via cURL:
```bash
curl -u "{code}:{password}" http://localhost:3000/r/{code}
```

## 🔌 API Reference

### Create a Shortened Link

```http
POST /api/v1/links
```

**Request Body:**
```json
{
  "url": "https://example.com",
  "password": "mysecurepassword",  // Optional
  "expires_at": "2025-12-31T23:59:59Z"  // Optional
}
```

**Response:**
```json
{
  "original_url": "https://example.com",
  "short_url": "http://localhost:3000/r/Abc12345",
  "created_at": "2023-01-15T12:34:56Z",
  "expires_at": "2025-12-31T23:59:59Z",
  "code": "Abc12345",
  "clicks": 0
}
```

### Retrieve Link Information

```http
GET /api/v1/links/{code}
```

**Response:**
```json
{
  "original_url": "https://example.com",
  "short_url": "http://localhost:3000/r/Abc12345",
  "created_at": "2023-01-15T12:34:56Z",
  "expires_at": "2025-12-31T23:59:59Z",
  "code": "Abc12345",
  "clicks": 42
}
```

## 🧪 Development

```bash
# Run tests
rspec

# Run linting
rubocop
```

## 🚢 Deployment with Kamal

YLL supports deployment with [Kamal](https://kamal-deploy.org/), a deployment tool for Ruby on Rails applications that uses Docker and SSH.

### Prerequisites

- Docker installed locally
- SSH access to your production server
- Docker installed on your production server

### Configuration

1. Install the Kamal gem:
```bash
gem install kamal
```

2. Initialize Kamal in your project:
```bash
kamal init
```

3. Edit the generated `config/deploy.yml` file:
```yaml
service: yll
image: username/yll
registry:
  username: registry_username
  password:
    - KAMAL_REGISTRY_PASSWORD
servers:
  web:
    hosts:
      - your-server-ip
    labels:
      traefik.http.routers.yll.rule: Host(`yll.yourdomain.com`)
env:
  clear:
    DATABASE_URL: postgres://username:password@db-host/yll_production
    RAILS_ENV: production
    HOST_URL: https://yll.yourdomain.com
volumes:
  - /path/on/host/storage:/rails/storage
```

### Deployment Commands

```bash
# Build and push the Docker image
kamal setup

# Deploy the application
kamal deploy

# Check deployment status
kamal status

# View logs
kamal logs

# Rollback to previous version
kamal rollback
```

### Continuous Deployment

You can set up continuous deployment using GitHub Actions:

1. Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.4'
      - name: Install Kamal
        run: gem install kamal
      - name: Deploy
        run: kamal deploy
        env:
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
```

## 🛡️ Security Features

- HTTPS enforcement for destination URLs
- URL validation and availability checking
- Rate limiting to prevent abuse
- Password protection using secure hashing

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💡 Implementation Details

YLL uses Rails' `has_secure_password` for password protection and implements various validations:

- URL format and security validation
- Unique code generation
- Expiration time validation
- URL availability checking

Rate limiting is implemented to prevent abuse, and the application follows Rails best practices for security and performance.