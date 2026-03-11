# Kuma San Kanji

## Project Overview

This project is a web application for learning Japanese Kanji, named "Kuma San Kanji". It is built with the Elixir programming language, using the Phoenix web framework and the Ash resource-oriented framework. The application uses PostgreSQL for its database and Auth0 for user authentication. The frontend is built using Tailwind CSS and esbuild.

The application is designed to help users learn and review Kanji, and it includes a spaced repetition system (SRS) for tracking user progress. The SRS is based on the SM-2 algorithm.

## Building and Running

To build and run the project, you will need to have Elixir and Erlang installed. You will also need to have PostgreSQL running.

1.  **Install dependencies:**

    ```bash
    mix setup
    ```

2.  **Set up the database:**

    You will need to create a PostgreSQL database and configure the connection details in `config/dev.exs`.

3.  **Run the database migrations:**

    ```bash
    mix ecto.create
    mix ecto.migrate
    ```

4.  **Start the Phoenix server:**

    ```bash
    mix phx.server
    ```

The application will then be available at [http://localhost:4000](http://localhost:4000).

### Running Tests

To run the test suite, use the following command:

```bash
mix test
```

## Development Conventions

The project follows the standard conventions for Elixir and Phoenix projects. The Ash framework is used for defining resources and their interactions.

The code is organized into domains, with each domain representing a specific part of the application. The main domains are:

*   `KumaSanKanji.Accounts`: Manages users and authentication.
*   `KumaSanKanji.Content`: Manages the Kanji content, including thematic groups, educational context, and usage examples. The core resource is `KumaSanKanji.Kanji.Kanji` which represents a single Kanji character and its associated data.
*   `KumaSanKanji.SRS`: Manages the spaced repetition system. This is implemented using the SM-2 algorithm, and the core logic is in the `KumaSanKanji.SRS.UserKanjiProgress` resource.

The frontend assets are located in the `assets` directory and are built using `esbuild` and `tailwind`.

## Routing

The application's routes are defined in `lib/kuma_san_kanji_web/router.ex`. It uses `AshAuthentication.Phoenix.Router` to handle authentication-related routes. The application has public routes, authenticated routes, and admin routes. The main routes are:

*   `/`: The home page.
*   `/explore`: The explore page.
*   `/radicals/:id`: The radical page.
*   `/credits`: The credits page.
*   `/quiz`: The quiz page (requires authentication).
*   `/admin`: The admin dashboard (requires authentication).

## Frontend

The frontend is built using Phoenix LiveView. The main JavaScript file is `assets/js/app.js`. This file sets up the LiveView socket and defines several hooks for interactivity, including:

*   `KanjiStrokeOrderAnimate`: Animates the stroke order of Kanji characters.
*   `StrokeOrderToggle`: Toggles the visibility of the stroke order.
*   `MobileMenu`: Manages the mobile navigation menu.
*   `FocusInput`: Focuses input fields.
*   `MobileSwipeGestures`: Handles swipe gestures for the quiz.

## Docker

The project includes a comprehensive Docker setup for development, production, and Docker Swarm deployments.

### Dockerfiles

*   `Dockerfile.dev`: This Dockerfile is used for the development environment. It sets up the Elixir environment, installs dependencies, and runs the Phoenix server with live reload.
*   `Dockerfile`: This is the production Dockerfile. It uses a multi-stage build to create a minimal runtime image.
*   `Dockerfile.swarm`: This Dockerfile is similar to the production Dockerfile but includes a health check for use with Docker Swarm.

### Docker Compose

The `docker-compose.yml` file is used to orchestrate the development environment. It defines the `app` service, which uses the `Dockerfile.dev` to build the development image. The local database service has been removed in favor of Fly Postgres.

### Docker Aliases

The `mix.exs` file defines several aliases for working with Docker:

*   `mix assets.deploy`: This alias is used to build the assets for production.