export type Workout = {
  id: string;
  user_id: string;
  date: string;
};

export type Exercise = {
  id: string;
  name: string;
  description?: string;
};

export type Goal = {
  id: string;
  workout_id: string;
  description: string;
  target: number;
  progress: number;
};

export type WorkoutExercise = {
  workout_id: string;
  exercise_id: string;
  sets: number;
  reps: number;
};
