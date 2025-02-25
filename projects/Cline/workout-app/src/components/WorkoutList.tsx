"use client";

import React from 'react';
import { Workout } from '@/types/types';

interface WorkoutListProps {
  workouts: Workout[];
}

const WorkoutList = ({ workouts }: WorkoutListProps) => {
  return (
    <div>
      <h2>Workouts</h2>
      {workouts.length === 0 ? (
        <p>No workouts yet!</p>
      ) : (
        <ul>
          {workouts.map((workout) => (
            <li key={workout.id}>{workout.date}</li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default WorkoutList;
