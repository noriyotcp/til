import React, { useState, useEffect } from 'react';
import { Exercise } from '@/types/types';

interface AddExercisesToWorkoutProps {
  workoutId: string;
}

const AddExercisesToWorkout = ({ workoutId }: AddExercisesToWorkoutProps) => {
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [selectedExercises, setSelectedExercises] = useState<string[]>([]);

  useEffect(() => {
    const fetchExercises = async () => {
      const response = await fetch('/api/exercises');
      const data = await response.json();
      setExercises(data);
    };

    fetchExercises();
  }, []);

  const handleCheckboxChange = (exerciseId: string) => {
    setSelectedExercises((prevSelectedExercises) => {
      if (prevSelectedExercises.includes(exerciseId)) {
        return prevSelectedExercises.filter((id) => id !== exerciseId);
      } else {
        return [...prevSelectedExercises, exerciseId];
      }
    });
  };

  const [message, setMessage] = useState<string | null>(null);

  const handleAddExercises = async () => {
    const response = await fetch('/api/workout_exercises', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        workoutId,
        exerciseIds: selectedExercises,
      }),
    });

    if (response.ok) {
      setMessage('Exercises added to workout successfully!');
    } else {
      const errorData = await response.json();
      setMessage('Failed to add exercises to workout.');
      console.error('Failed to add exercises to workout:', errorData.error);
    }
  };

  return (
    <div>
      <h2>Add Exercises to Workout</h2>
      {message && <p>{message}</p>}
      <ul>
        {exercises.map((exercise) => (
          <li key={exercise.id}>
            <label>
              <input
                type="checkbox"
                value={exercise.id}
                checked={selectedExercises.includes(exercise.id)}
                onChange={() => handleCheckboxChange(exercise.id)}
              />
              {exercise.name}
            </label>
          </li>
        ))}
      </ul>
      <button onClick={handleAddExercises}>Add Exercises</button>
    </div>
  );
};

export default AddExercisesToWorkout;
