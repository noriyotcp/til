import { createClient } from "@/utils/supabase/server";
import { NextResponse } from "next/server";

interface Params {
  id: string;
}

export async function PUT(
  request: Request,
  { params }: { params: Params }
) {
  const supabase = await createClient();
  const { id } = params;
  const { date } = await request.json();

  const { data, error } = await supabase
    .from("workouts")
    .update({ date })
    .eq("id", id)
    .select()
    .single();

  if (error) {
    console.error(error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json(data);
}

export async function GET(
  request: Request,
  { params }: { params: Params }
) {
  const supabase = await createClient();
  const { id } = await params;

  const { data: exercises, error: exercisesError } = await supabase
    .from("workout_exercises")
    .select("exercise_id, sets, reps")
    .eq("workout_id", id)

  if (exercisesError) {
    console.error(exercisesError);
    return NextResponse.json({ error: exercisesError.message }, { status: 500 });
  }

  return NextResponse.json(exercises);
}

export async function DELETE(
  request: Request,
  { params }: { params: Params }
) {
  const supabase = await createClient();
  const { id } = params;

  const { error } = await supabase.from("workouts").delete().eq("id", id);

  if (error) {
    console.error(error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json({ success: true }, { status: 200 });
}
