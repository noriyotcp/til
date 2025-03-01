import React, { useState } from 'react';
import { useWorkouts } from '@/context/WorkoutsContext';

interface WorkoutSelectorProps {
  onWorkoutSelect: (workoutId: string) => void;
}

const WorkoutSelector = ({ onWorkoutSelect }: WorkoutSelectorProps) => {
  const { workouts } = useWorkouts();
  const [selectedWorkout, setSelectedWorkout] = useState<string | null>(null);

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
