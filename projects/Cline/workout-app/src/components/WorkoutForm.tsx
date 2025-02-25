"use client";

import React, { useState } from 'react';
import { supabase } from '@/utils/supabase/client';
import useAuth from '@/hooks/useAuth';

const WorkoutForm = () => {
  const { userId } = useAuth();
  const [date, setDate] = useState('');

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();

    if (!userId) {
      console.error('User not authenticated');
      return;
    }

    const { data, error } = await supabase
      .from('workouts')
      .insert([{ user_id: userId, date }]);

    if (error) {
      console.error('Error inserting workout:', error);
    } else {
      console.log('Workout inserted successfully:', data);
      setDate('');
    }
  };

  return (
    <div>
      <h2>Add Workout</h2>
      <form onSubmit={handleSubmit}>
        <label htmlFor="date">Date:</label>
        <input
          type="date"
          id="date"
          value={date}
          onChange={(event) => setDate(event.target.value)}
          required
        />
        <button type="submit">Add Workout</button>
      </form>
    </div>
  );
};

export default WorkoutForm;
