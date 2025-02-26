-- Update goals table
ALTER TABLE goals
RENAME COLUMN user_id TO workout_id;
