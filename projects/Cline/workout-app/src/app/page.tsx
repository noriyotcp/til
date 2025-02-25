import WorkoutList from '@/components/WorkoutList';
import WorkoutForm from '@/components/WorkoutForm';
import ExerciseList from '@/components/ExerciseList';
import GoalList from '@/components/GoalList';
import GoalForm from '@/components/GoalForm';
import ProgressChart from '@/components/ProgressChart';
import RecommendationList from '@/components/RecommendationList';
import { supabase } from '@/lib/supabaseClient';

async function getWorkouts() {
  const { data, error } = await supabase
    .from('workouts')
    .select('*');

  if (error) {
    console.error('Error fetching workouts:', error);
    return [];
  }

  return data;
}

export default async function Home() {
  const workouts = await getWorkouts();

  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <WorkoutList workouts={workouts} />
      <WorkoutForm />
      <ExerciseList />
      <GoalList />
      <GoalForm />
      <ProgressChart />
      <RecommendationList />
    </main>
  );
}
