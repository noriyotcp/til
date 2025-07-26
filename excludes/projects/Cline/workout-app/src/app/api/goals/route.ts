import { createClient } from "@/utils/supabase/server";
import { NextResponse } from "next/server";

export async function GET(request: Request) {
  const supabase = await createClient();
  const { searchParams } = new URL(request.url);
  const workoutDate = searchParams.get('workoutDate');

  let query = supabase.from("goals").select(`
      *,
      workouts (
        date
      )
    `);

  if (workoutDate) {
    const { data: workouts, error: workoutError } = await supabase
      .from("workouts")
      .select("id")
      .eq("date", workoutDate)
      .single();

    if (workoutError) {
      console.error(workoutError);
      return NextResponse.json({ error: workoutError.message }, { status: 500 });
    }

    if (workouts) {
      query = query.eq("workout_id", workouts.id);
    } else {
      return NextResponse.json([], { status: 200 }); // No workout found for the given date
    }
  }

  const { data, error } = await query;

  if (error) {
    console.error(error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json(data);
}

export async function POST(request: Request) {
  const supabase = await createClient();

  const { workout_id, description, target, progress } = await request.json();

  if (!workout_id) {
    return NextResponse.json({ error: 'No workout selected' }, { status: 400 });
  }

  const { data, error } = await supabase
    .from("goals")
    .insert({ workout_id, description, target, progress });

  if (error) {
    console.error(error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json(data, { status: 201 });
}
