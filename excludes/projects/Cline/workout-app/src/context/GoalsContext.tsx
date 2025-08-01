"use client";

import React, { createContext, useState, useEffect, useContext, useCallback } from 'react';
import { Goal } from '@/types/types';

interface GoalsContextType {
  goals: Goal[];
  setGoals: React.Dispatch<React.SetStateAction<Goal[]>>;
  fetchGoals: (workoutDate: string | null) => Promise<void>;
}

const GoalsContext = createContext<GoalsContextType | undefined>(undefined);

export const GoalsProvider = ({ children }: { children: React.ReactNode }) => {
  const [goals, setGoals] = useState<Goal[]>([]);

  const fetchGoals = useCallback(async (workoutDate: string | null) => {
    let url = '/api/goals';
    if (workoutDate) {
      url += `?workoutDate=${workoutDate}`;
    }
    const response = await fetch(url);
    const data = await response.json();
    setGoals(data);
  }, []);

  useEffect(() => {
    fetchGoals(null);
  }, [fetchGoals]);

  const value: GoalsContextType = {
    goals,
    setGoals,
    fetchGoals,
  };

  return (
    <GoalsContext.Provider value={value}>
      {children}
    </GoalsContext.Provider>
  );
};

export const useGoals = () => {
  const context = useContext(GoalsContext);
  if (!context) {
    throw new Error('useGoals must be used within a GoalsProvider');
  }
  return context;
};
