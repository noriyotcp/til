"use client";

import React, { createContext, useState, useEffect, useContext } from 'react';
import { Workout } from '@/types/types';
import useAuth from '@/hooks/useAuth';

interface WorkoutsContextType {
  workouts: Workout[];
  setWorkouts: React.Dispatch<React.SetStateAction<Workout[]>>;
  fetchWorkouts: () => Promise<void>;
}

const WorkoutsContext = createContext<WorkoutsContextType | undefined>(undefined);

export const WorkoutsProvider = ({ children }: { children: React.ReactNode }) => {
  const [workouts, setWorkouts] = useState<Workout[]>([]);
  const { userId } = useAuth();

  const fetchWorkouts = async () => {
    if (!userId) return;
    const response = await fetch('/api/workouts');
    const data = await response.json();
    setWorkouts(data);
  };

  useEffect(() => {
    fetchWorkouts();
  }, [userId]);

  const value: WorkoutsContextType = {
    workouts,
    setWorkouts,
    fetchWorkouts,
  };

  return (
    <WorkoutsContext.Provider value={value}>
      {children}
    </WorkoutsContext.Provider>
  );
};

export const useWorkouts = () => {
  const context = useContext(WorkoutsContext);
  if (!context) {
    throw new Error('useWorkouts must be used within a WorkoutsProvider');
  }
  return context;
};
