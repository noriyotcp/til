import React, { useState, useEffect } from 'react';
import { Workout } from '@/types/types';

interface WorkoutDetailsProps {
  workout: Workout;
}

const WorkoutDetails = ({ workout }: WorkoutDetailsProps) => {
  const [exercises, setExercises] = useState<
    {
      id: string;
      name: string;
      description?: string;
      sets: number;
      reps: number;
    }[]
  >([]);

  useEffect(() => {
    const fetchExercises = async () => {
      const response = await fetch(`/api/workouts/${workout.id}`);
      const data = await response.json();

      if (data) {
        const exerciseDetails = await Promise.all(
          data.map(async (item: { exercise_id: string, sets: number, reps: number }) => {
            const exerciseResponse = await fetch(`/api/exercises/${item.exercise_id}`);
            const exerciseData = await exerciseResponse.json();
            return {
              ...exerciseData,
              sets: item.sets,
              reps: item.reps,
            };
          })
        );
        setExercises(exerciseDetails);
      } else {
        setExercises([]);
      }
    };

    fetchExercises();
  }, [workout.id]);

  return (
    <div>
      <h3>{workout.date}</h3>
      {exercises && exercises.length > 0 ? (
        <ul>
          {exercises.map((exercise) => (
            <li key={exercise.id}>
              {exercise.name} - Sets: {exercise.sets}, Reps: {exercise.reps}
            </li>
          ))}
        </ul>
      ) : (
        <p>No exercises for this workout.</p>
      )}
    </div>
  );
};

export default WorkoutDetails;
