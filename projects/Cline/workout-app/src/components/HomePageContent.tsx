"use client";

import React, { useState } from 'react';
import WorkoutList from '@/components/WorkoutList';
import ExerciseList from '@/components/ExerciseList';
import GoalList from '@/components/GoalList';
import GoalForm from '@/components/GoalForm';
import ProgressChart from '@/components/ProgressChart';
import RecommendationList from '@/components/RecommendationList';
import WorkoutForm from '@/components/WorkoutForm';
import Link from 'next/link';
import { useAuth } from '@/context/AuthContext';
import LogoutButton from './LogoutButton';

import { Workout } from '@/types/types';

interface HomePageContentProps {
  workouts: Workout[];
}

const HomePageContent = ({ workouts }: HomePageContentProps) => {
  const { userId } = useAuth();
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);

  const handleDateSelect = (date: Date | null) => {
    setSelectedDate(date);
  };

  return (
    <>
      {userId ? (
        <>
          <LogoutButton />
          <WorkoutForm />
          <WorkoutList onDateSelect={handleDateSelect} workouts={workouts} />
          <ExerciseList />
          <GoalList selectedDate={selectedDate} />
          <GoalForm />
          <ProgressChart />
          <RecommendationList />
        </>
      ) : (
        <>
          <Link href="/login">Log In</Link>
          <Link href="/signup">Sign Up</Link>
          <p>Please sign up to add workouts.</p>
        </>
      )}
    </>
  );
};

export default HomePageContent;
