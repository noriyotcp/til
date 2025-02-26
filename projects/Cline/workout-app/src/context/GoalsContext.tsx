"use client";

import React, { createContext, useState, useEffect, useContext } from 'react';
import { Goal } from '@/types/types';

interface GoalsContextType {
  goals: Goal[];
  setGoals: React.Dispatch<React.SetStateAction<Goal[]>>;
  fetchGoals: () => Promise<void>;
}

const GoalsContext = createContext<GoalsContextType | undefined>(undefined);

export const GoalsProvider = ({ children }: { children: React.ReactNode }) => {
  const [goals, setGoals] = useState<Goal[]>([]);

  const fetchGoals = async () => {
    const response = await fetch('/api/goals');
    const data = await response.json();
    setGoals(data);
  };

  useEffect(() => {
    fetchGoals();
  }, []);

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
