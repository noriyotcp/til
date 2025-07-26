-- Create goals table
CREATE TABLE goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES workouts(id) NOT NULL,
  description VARCHAR(255) NOT NULL,
  target INTEGER NOT NULL,
  progress INTEGER NOT NULL
);
