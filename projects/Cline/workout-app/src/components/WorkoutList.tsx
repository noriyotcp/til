"use client";

import React, { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabaseClient';
import { Workout } from '@/types/types';

const WorkoutList = () => {
  const [workouts, setWorkouts] = useState<Workout[]>([]);

  useEffect(() => {
    const fetchWorkouts = async () => {
      const { data, error } = await supabase
        .from('workouts')
        .select('*');

      if (error) {
        console.error('Error fetching workouts:', error);
      } else {
        setWorkouts(data || []);
      }
    };

    fetchWorkouts();
  }, []);

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
