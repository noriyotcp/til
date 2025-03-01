"use client";

"use client";

import React, { useState } from 'react';
import { supabase } from '@/utils/supabase/client';
import useAuth from '@/hooks/useAuth';
import { useWorkouts } from '@/context/WorkoutsContext';

const WorkoutForm = () => {
  const { userId } = useAuth();
  const [date, setDate] = useState('');
  const { fetchWorkouts } = useWorkouts();

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();

    if (!userId) {
      console.error('User not authenticated');
      return;
    }

    const { data, error } = await supabase
      .from('workouts')
      .insert([{ user_id: userId, date }])
      .select();

    if (error) {
      console.error('Error inserting workout:', error);
    } else {
      console.log('Workout inserted successfully:', data);
      setDate('');
      fetchWorkouts();
    }
  };

  return (
    <div className="bg-gray-800 p-4 rounded-lg shadow-md">
      <h2 className="text-xl font-bold">Add Workout</h2>
      <form onSubmit={handleSubmit}>
        <label className="block mt-2">
          Date:
          <input
            type="date"
            id="date"
            value={date}
            onChange={(event) => setDate(event.target.value)}
            required
            className="mt-1 p-2 w-full bg-background text-foreground rounded"
          />
        </label>
        <button type="submit" className="mt-4 bg-accent text-white p-2 rounded">Add Workout</button>
      </form>
    </div>
  );
};

export default WorkoutForm;
