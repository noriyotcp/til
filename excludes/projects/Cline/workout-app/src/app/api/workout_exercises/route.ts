import { createClient } from "@/utils/supabase/server";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  const supabase = await createClient();
  const { workoutId, exerciseIds } = await request.json();

  console.log('Received workoutId:', workoutId);
  console.log('Received exerciseIds:', exerciseIds);

  try {
    // Create an array of promises to insert each workout_exercise
    const insertPromises = exerciseIds.map((exerciseId: string) =>
      supabase
        .from("workout_exercises")
        .insert({ workout_id: workoutId, exercise_id: exerciseId, sets: 1, reps: 1 })
        .select() // Add select to return the inserted row
    );

    // Wait for all inserts to complete
    const results = await Promise.all(insertPromises);

    console.log('Insert results:', results);

    return NextResponse.json({ message: "Exercises added to workout successfully" }, { status: 200 });
  } catch (error: unknown) {
    console.error(error);
    let message = 'An unexpected error occurred';
    if (error instanceof Error) {
      message = error.message;
    }
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
