-- Create followers table
CREATE TABLE IF NOT EXISTS public.followers (
  follower_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  seller_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (follower_id, seller_id)
);

-- Enable Row Level Security
ALTER TABLE public.followers ENABLE ROW LEVEL SECURITY;

-- Create policies for followers table
CREATE POLICY "Users can view their own follows"
  ON public.followers
  FOR SELECT
  USING (auth.uid() = follower_id);

CREATE POLICY "Users can view who they are following"
  ON public.followers
  FOR SELECT
  USING (auth.uid() = seller_id);

CREATE POLICY "Users can follow sellers"
  ON public.followers
  FOR INSERT
  WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can unfollow sellers"
  ON public.followers
  FOR DELETE
  USING (auth.uid() = follower_id);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_followers_follower_id ON public.followers(follower_id);
CREATE INDEX IF NOT EXISTS idx_followers_seller_id ON public.followers(seller_id);

-- Allow users to see public profiles (if you have a profiles table)
-- This assumes you have a profiles table with public user information
CREATE OR REPLACE FUNCTION public.get_user_profile(user_id UUID)
RETURNS JSON
LANGUAGE SQL
SECURITY DEFINER
AS $$
  SELECT row_to_json(profiles.*)
  FROM public.profiles
  WHERE id = user_id;
$$;
