-- Add created_at column to wishlist table if it doesn't exist
ALTER TABLE public.wishlist 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- Create an index on created_at for better query performance
CREATE INDEX IF NOT EXISTS idx_wishlist_created_at ON public.wishlist(created_at);
