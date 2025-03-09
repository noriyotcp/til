import React, { useState, useEffect } from 'react';
import { Exercise } from '@/types/types';

const ExerciseList = () => {
  const [exercises, setExercises] = useState<Exercise[]>([]);

  useEffect(() => {
    const fetchExercises = async () => {
      const response = await fetch('/api/exercises');
      const data = await response.json();
      setExercises(data);
    };

    fetchExercises();
  }, []);

  return (
    <div className="container mx-auto mt-8">
      <h3 className="text-2xl font-bold mb-4">Exercises</h3>
      <ul>
        {exercises.map((exercise) => (
          <li key={exercise.id} className="mb-2 p-2 border rounded">
            {exercise.name}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default ExerciseList;
