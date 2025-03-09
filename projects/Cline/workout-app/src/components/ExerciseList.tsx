import React, { useState, useEffect } from 'react';
import { Exercise } from '@/types/types';
import ExerciseForm from './ExerciseForm';

const ExerciseList = () => {
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [showForm, setShowForm] = useState(false);

  const fetchExercises = async () => {
    const response = await fetch('/api/exercises');
    const data = await response.json();
    setExercises(data);
  };

  useEffect(() => {
    fetchExercises();
  }, []);

  const handleExerciseCreated = () => {
    fetchExercises();
  };

  return (
    <div className="container mx-auto mt-8">
      <h3 className="text-2xl font-bold mb-4">Exercises</h3>
      <button
        className="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline mb-4"
        onClick={() => setShowForm(!showForm)}
      >
        Create Exercise
      </button>
      {showForm && <ExerciseForm onExerciseCreated={handleExerciseCreated} />}
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
