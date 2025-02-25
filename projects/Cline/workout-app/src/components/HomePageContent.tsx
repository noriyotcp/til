"use client";

import React from 'react';
import WorkoutList from '@/components/WorkoutList';
import ExerciseList from '@/components/ExerciseList';
import GoalList from '@/components/GoalList';
import GoalForm from '@/components/GoalForm';
import ProgressChart from '@/components/ProgressChart';
import RecommendationList from '@/components/RecommendationList';
import WorkoutForm from '@/components/WorkoutForm';
import Link from 'next/link';
import { useAuth } from '@/context/AuthContext';
import { Workout } from '@/types/types';

interface HomePageContentProps {
  workouts: Workout[];
}

const HomePageContent = ({ workouts }: HomePageContentProps) => {
  const { userId } = useAuth();

  return (
    <>
      <Link href="/signup">Sign Up</Link>
      {userId ? (
        <>
          <WorkoutForm />
          <WorkoutList workouts={workouts} />
          <ExerciseList />
          <GoalList />
          <GoalForm />
          <ProgressChart />
          <RecommendationList />
        </>
      ) : (
        <p>Please sign up to add workouts.</p>
      )}
    </>
  );
};

export default HomePageContent;
