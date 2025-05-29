-- Create profiles table
create table if not exists public.profiles (
  id uuid not null primary key references auth.users(id) on delete cascade,
  username text not null unique,
  bio text default '',
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security
alter table public.profiles enable row level security;

-- Create policies
-- Allow public read access to all profiles
create policy "Public profiles are viewable by everyone." 
on public.profiles for select 
using (true);

-- Allow users to insert their own profile
create policy "Users can insert their own profile." 
on public.profiles for insert 
with check (auth.uid() = id);

-- Allow users to update their own profile
create policy "Users can update own profile." 
on public.profiles for update 
using (auth.uid() = id);

-- Create a function to handle the updated_at timestamp
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Create a trigger to update the updated_at column on update
create trigger handle_profiles_updated_at
  before update on public.profiles
  for each row
  execute function public.handle_updated_at();

-- Create a function to handle new user signups
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username)
  values (new.id, new.raw_user_meta_data->>'username');
  return new;
end;
$$ language plpgsql security definer;

-- Create a trigger to create a profile when a new user signs up
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Create indexes for better performance
create index if not exists idx_profiles_username on public.profiles (username);
create index if not exists idx_profiles_created_at on public.profiles (created_at);

-- Add comments
do $$
begin
  if not exists (
    select 1
    from pg_catalog.pg_description
    where objoid = 'public.profiles'::regclass
  ) then
    comment on table public.profiles is 'User profile information';
    comment on column public.profiles.id is 'References the auth.users table';
    comment on column public.profiles.username is 'Unique username for the user';
    comment on column public.profiles.bio is 'User bio/description';
    comment on column public.profiles.avatar_url is 'URL to the user''s avatar image';
    comment on column public.profiles.created_at is 'Timestamp when the profile was created';
    comment on column public.profiles.updated_at is 'Timestamp when the profile was last updated';
  end if;
end $$;
