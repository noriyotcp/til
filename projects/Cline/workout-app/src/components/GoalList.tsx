import React from 'react';
import { useGoals } from '@/context/GoalsContext';

const GoalList = () => {
  const { goals } = useGoals();

  return (
    <div>
      <h2>Goals</h2>
      <ul>
        {Array.isArray(goals) ? (
          goals.map((goal) => (
            <li key={goal.id}>{goal.description} (Workout ID: {goal.workout_id})</li>
          ))
        ) : (
          <li>No goals yet!</li>
        )}
      </ul>
    </div>
  );
};

export default GoalList;
