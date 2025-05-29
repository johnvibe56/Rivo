-- Create a function to handle new profile creation
create or replace function public.handle_new_profile(
  p_user_id uuid,
  p_username text
)
returns json
language plpgsql
security definer
as $$
declare
  v_profile_id uuid;
  v_username_available boolean;
  v_username_suffix int := 1;
  v_available_username text := p_username;
  v_error_message text;
begin
  -- Check if username is available
  select not exists (
    select 1 from public.profiles 
    where username = p_username
  ) into v_username_available;
  
  -- If username is taken, append a number and try again (max 10 attempts)
  while not v_username_available and v_username_suffix <= 10 loop
    v_available_username := p_username || v_username_suffix::text;
    
    select not exists (
      select 1 from public.profiles 
      where username = v_available_username
    ) into v_username_available;
    
    v_username_suffix := v_username_suffix + 1;
  end loop;
  
  -- If we still don't have an available username, use a UUID
  if not v_username_available then
    v_available_username := 'user_' || replace(gen_random_uuid()::text, '-', '_');
  end;
  
  -- Insert the new profile
  insert into public.profiles (id, username)
  values (p_user_id, v_available_username)
  returning id into v_profile_id;
  
  -- Return the new profile
  return json_build_object(
    'id', v_profile_id,
    'username', v_available_username,
    'bio', '',
    'avatar_url', null,
    'created_at', now(),
    'updated_at', now()
  );
  
exception when others then
    v_error_message := 'Failed to create profile: ' || SQLERRM;
    raise exception '%', v_error_message using errcode = 'P0001';
end;
$$;

-- Grant execute permission to authenticated users
grant execute on function public.handle_new_profile(uuid, text) to authenticated;
