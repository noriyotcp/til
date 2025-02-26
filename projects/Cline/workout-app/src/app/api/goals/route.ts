import { createClient } from "@/utils/supabase/server";
import { NextResponse } from "next/server";

export async function GET() {
  const supabase = await createClient();

  const { data, error } = await supabase.from("goals").select("*");

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
