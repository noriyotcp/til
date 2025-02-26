import React, { useState } from 'react';
import useAuth from '@/hooks/useAuth';
import { useGoals } from '@/context/GoalsContext';
import WorkoutSelector from './WorkoutSelector';

const GoalForm = () => {
  const [description, setDescription] = useState('');
  const [target, setTarget] = useState(0);
  const [progress, setProgress] = useState(0);
  const [workoutId, setWorkoutId] = useState<string | null>(null);
  const { userId } = useAuth();
  const { fetchGoals } = useGoals();

  const handleWorkoutSelect = (workoutId: string) => {
    setWorkoutId(workoutId);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!userId) {
      console.error('User not authenticated');
      return;
    }

    if (!workoutId) {
      console.error('No workout selected');
      return;
    }

    const response = await fetch('/api/goals', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        workout_id: workoutId,
        description,
        target,
        progress,
      }),
    });

    if (response.ok) {
      // Reset form
      setDescription('');
      setTarget(0);
      setProgress(0);
      // Fetch goals to update the list
      fetchGoals();
    } else {
      console.error('Failed to create goal');
    }
  };

  return (
    <div>
      <h2>Add Goal</h2>
      <form onSubmit={handleSubmit}>
        <WorkoutSelector onWorkoutSelect={handleWorkoutSelect} />
        <label>
          Description:
          <input
            type="text"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />
        </label>
        <label>
          Target:
          <input
            type="number"
            value={target}
            onChange={(e) => setTarget(Number(e.target.value))}
          />
        </label>
        <label>
          Progress:
          <input
            type="number"
            value={progress}
            onChange={(e) => setProgress(Number(e.target.value))}
          />
        </label>
        <button type="submit" disabled={!workoutId}>Create Goal</button>
      </form>
    </div>
  );
};

export default GoalForm;
