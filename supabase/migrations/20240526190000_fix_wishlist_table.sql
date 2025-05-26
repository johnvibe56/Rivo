-- Ensure the wishlist table exists with the correct structure
CREATE TABLE IF NOT EXISTS public.wishlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_wishlist_user_id ON public.wishlist(user_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_product_id ON public.wishlist(product_id);

-- Enable Row Level Security
ALTER TABLE public.wishlist ENABLE ROW LEVEL SECURITY;

-- Create policies for secure access
DROP POLICY IF EXISTS "Users can view their own wishlist items" ON public.wishlist;
CREATE POLICY "Users can view their own wishlist items"
  ON public.wishlist
  FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can add to their own wishlist" ON public.wishlist;
CREATE POLICY "Users can add to their own wishlist"
  ON public.wishlist
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can remove from their own wishlist" ON public.wishlist;
CREATE POLICY "Users can remove from their own wishlist"
  ON public.wishlist
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create a function to check if a product is in the wishlist
CREATE OR REPLACE FUNCTION public.is_product_in_wishlist(p_product_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 
    FROM public.wishlist 
    WHERE product_id = p_product_id 
    AND user_id = auth.uid()
  );
$$ LANGUAGE SQL SECURITY DEFINER;
