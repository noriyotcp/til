import HomePageContent from '@/components/HomePageContent';
import { supabase } from '@/utils/supabase/client';

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

const Home = async () => {
  const workouts = await getWorkouts();

  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <div className="container max-w-3xl">
        <HomePageContent workouts={workouts} />
      </div>
    </main>
  );
}

export default Home;
