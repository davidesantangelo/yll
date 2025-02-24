# YLL

## Overview
YLL is a URL shortener built with Ruby on Rails. It allows users to create short links with optional expiration times and password protection.

## Features
- Shorten URLs with a unique 8-character code
- Expiring links with an optional expiration time
- Password-protected links using HTTP Basic Authentication
- Click tracking for each shortened URL
- JSON API for link creation and retrieval

## Installation
```sh
git clone https://github.com/davidesantangelo/yll.git
cd yll
bundle install
rails db:migrate
rails server
```

## Usage
### Shortening a URL
You can create a shortened URL using the API:
```sh
curl -X POST "http://localhost:3000/api/v1/links" -d "url=https://example.com"
```

### Redirecting to the Original URL
Accessing the shortened link will redirect to the original URL:
```sh
http://localhost:3000/r/{code}
```

### Password-Protected Links
If a link is password-protected, the browser will prompt for credentials using HTTP Basic Authentication. 
- **Username**: The short code of the link
- **Password**: The password set when the link was created

For example, when accessing a password-protected link, the browser will display a login prompt asking for credentials. You must enter the short code as the username and the configured password to proceed.

Alternatively, you can provide credentials via cURL:
```sh
curl -u "{code}:{password}" http://localhost:3000/r/{code}
```

## API Endpoints
### Create a Shortened Link
```http
POST /api/v1/links
```
**Request Body:**
```json
{
  "url": "https://example.com",
  "password": "mysecurepassword",
  "expires_at": "2025-12-31T23:59:59Z"
}
```

### Retrieve a Shortened Link
```http
GET /api/v1/links/{code}
```

## Development
To run the test suite:
```sh
rspec
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License.

