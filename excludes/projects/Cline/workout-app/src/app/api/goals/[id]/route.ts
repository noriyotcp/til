import { createClient } from "@/utils/supabase/server";
import { NextResponse } from "next/server";

interface Params {
  id: string;
}

export async function PUT(request: Request, { params }: { params: Params }) {
  const supabase = await createClient();
  const id = params.id;

  const { workout_id, description, target, progress } = await request.json();

  const { data, error } = await supabase
    .from("goals")
    .update({ workout_id, description, target, progress })
    .eq("id", id)
    .select();

  if (error) {
    console.error(error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json(data, { status: 200 });
}

export async function DELETE(request: Request, { params }: { params: Params }) {
  const supabase = await createClient();
  const id = params.id;

  const { error } = await supabase.from("goals").delete().eq("id", id);

  if (error) {
    console.error(error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json({ message: 'Goal deleted' }, { status: 200 });
}
