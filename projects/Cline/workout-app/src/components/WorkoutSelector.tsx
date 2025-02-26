import React, { useState, useEffect } from 'react';
import { Workout } from '@/types/types';

interface WorkoutSelectorProps {
  onWorkoutSelect: (workoutId: string) => void;
}

const WorkoutSelector = ({ onWorkoutSelect }: WorkoutSelectorProps) => {
  const [workouts, setWorkouts] = useState<Workout[]>([]);
  const [selectedWorkout, setSelectedWorkout] = useState<string | null>(null);

  useEffect(() => {
    const fetchWorkouts = async () => {
      const response = await fetch('/api/workouts');
      const data = await response.json();
      setWorkouts(data);
    };

    fetchWorkouts();
  }, []);

  const handleWorkoutChange = (event: React.ChangeEvent<HTMLSelectElement>) => {
    const workoutId = event.target.value;
    setSelectedWorkout(workoutId);
    onWorkoutSelect(workoutId);
  };

  return (
    <div>
      <label htmlFor="workout">Select Workout:</label>
      <select id="workout" value={selectedWorkout || ''} onChange={handleWorkoutChange}>
        <option value="">-- Select a workout --</option>
        {workouts.map((workout) => (
          <option key={workout.id} value={workout.id}>{workout.date}</option>
        ))}
      </select>
    </div>
  );
};

export default WorkoutSelector;
