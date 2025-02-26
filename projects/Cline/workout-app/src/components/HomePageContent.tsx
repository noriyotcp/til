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
import { logout } from '@/app/login/actions';

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
          <form action={logout}>
            <button type="submit">Logout</button>
          </form>
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
