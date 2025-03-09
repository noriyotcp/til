# System Patterns

## System Architecture

The application follows a Model-View-Controller (MVC) architecture.

-   **Model:** Supabase database for data storage and retrieval.
-   **View:** React components for rendering the user interface.
-   **Controller:** Next.js API routes for handling user requests and interacting with the database.

## Key Technical Decisions

-   Using Next.js for server-side rendering and API routes.
-   Using Supabase for user authentication and data storage.
-   Using Tailwind CSS for styling.

## Design Patterns in Use

-   Repository pattern for data access.
-   Context pattern for state management.

## Component Relationships

-   The `WorkoutForm` component allows users to add new workouts.
-   The `GoalForm` component allows users to set new goals.
-   The `WorkoutList` component displays a list of workouts.
-   The `GoalList` component displays a list of goals.
-   The `ProgressChart` component displays the user's progress over time.
