"use client";

import React, { useState, useCallback } from 'react';
import Calendar from 'react-calendar';
import 'react-calendar/dist/Calendar.css';
import { Workout } from '@/types/types';

type ValuePiece = Date | null;
type Value = ValuePiece | [ValuePiece, ValuePiece];

interface WorkoutListProps {
  workouts: Workout[];
  onDateSelect: (date: Date | null) => void;
}

const WorkoutList = ({ workouts, onDateSelect }: WorkoutListProps) => {
  const [value, setValue] = useState<Value>(null);

  const handleDateChange = useCallback(
    (date: Value) => {
      if (date instanceof Date) {
        setValue(date);
        onDateSelect(date);
      } else if (Array.isArray(date) && date.length > 0) {
        setValue(date[0]);
        onDateSelect(date[0]);
      } else {
        setValue(null);
        onDateSelect(null);
      }
    },
    [onDateSelect]
  );

  const handleClearDates = () => {
    setValue(null);
    onDateSelect(null);
  };

  const tileClassName = ({ date, view }: { date: Date; view: string }) => {
    if (view === "month") {
      const workoutDates = workouts.map((workout) =>
        new Date(workout.date).toDateString()
      );
      if (workoutDates.includes(date.toDateString())) {
        return "has-workout";
      }
    }
    return null;
  };

  return (
    <div>
      <h2>Workouts</h2>
      <div className="calendar-container">
        <Calendar
          onChange={handleDateChange}
          value={value}
          tileClassName={tileClassName}
        />
        <button
          onClick={handleClearDates}
          className="bg-blue-500 text-white p-2 rounded"
        >
          Clear Dates
        </button>
      </div>
    </div>
  );
};

export default WorkoutList;
