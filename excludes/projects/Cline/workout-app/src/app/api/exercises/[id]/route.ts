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
  const { name, description } = await request.json();

  const { data, error } = await supabase
    .from("exercises")
    .update({ name, description })
    .eq("id", id)
    .select()
    .single();

  if (error) {
    console.error(error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json(data);
}

export async function DELETE(
  request: Request,
  { params }: { params: Params }
) {
  const supabase = await createClient();
  const { id } = params;

  const { error } = await supabase.from("exercises").delete().eq("id", id);

  if (error) {
    console.error(error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json({ success: true }, { status: 200 });
}

export async function GET(
  request: Request,
  { params }: { params: Params }
) {
  const supabase = await createClient();
  const { id } = params;

  const { data, error } = await supabase
    .from("exercises")
    .select()
    .eq("id", id)
    .single();

  if (error) {
    console.error(error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json(data);
}
