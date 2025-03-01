"use client";

import React, { useState, useCallback } from 'react';
import Calendar from 'react-calendar';
import 'react-calendar/dist/Calendar.css';
import { useWorkouts } from '@/context/WorkoutsContext';

type ValuePiece = Date | null;
type Value = ValuePiece | [ValuePiece, ValuePiece];

interface WorkoutListProps {
  onDateSelect: (date: Date | null) => void;
}

const WorkoutList = ({ onDateSelect }: WorkoutListProps) => {
  const { workouts } = useWorkouts();
  const [value, setValue] = useState<Value>(new Date());

  const handleDateChange = useCallback((date: Value) => {
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
  }, [onDateSelect]);

  const tileClassName = ({ date, view }: { date: Date; view: string }) => {
    if (view === 'month') {
      const workoutDates = workouts.map(workout => new Date(workout.date).toDateString());
      if (workoutDates.includes(date.toDateString())) {
        return 'has-workout ';
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
      </div>
    </div>
  );
};

export default WorkoutList;
