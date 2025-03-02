"use client";

import React, { useState, useCallback } from 'react';
import { Workout } from '@/types/types';

interface WorkoutListProps {
  workouts: Workout[];
  onDateSelect: (date: Date | null) => void;
}

const WorkoutList = ({ onDateSelect }: WorkoutListProps) => {
  const [selectedDate, setSelectedDate] = useState<string | null>(null);

  const handleDateChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      const date = event.target.value;
      setSelectedDate(date);
      onDateSelect(date ? new Date(date) : null);
    },
    [onDateSelect]
  );

  return (
    <div className="bg-gray-800 p-4 rounded-lg shadow-md">
      <h2 className="text-xl font-bold">Workouts</h2>
      <div className="calendar-container">
        <input
          type="date"
          value={selectedDate || ""}
          onChange={handleDateChange}
          className="mt-1 p-2 w-full rounded"
        />
      </div>
    </div>
  );
};

export default WorkoutList;
