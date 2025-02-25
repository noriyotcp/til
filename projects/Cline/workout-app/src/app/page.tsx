import WorkoutList from '@/components/WorkoutList';
import WorkoutForm from '@/components/WorkoutForm';
import ExerciseList from '@/components/ExerciseList';
import GoalList from '@/components/GoalList';
import GoalForm from '@/components/GoalForm';
import ProgressChart from '@/components/ProgressChart';
import RecommendationList from '@/components/RecommendationList';

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <WorkoutList />
      <WorkoutForm />
      <ExerciseList />
      <GoalList />
      <GoalForm />
      <ProgressChart />
      <RecommendationList />
    </main>
  );
}
