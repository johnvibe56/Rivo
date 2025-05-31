-- Enable the pgcrypto extension for UUID generation
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create the purchases table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  buyer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  transaction_id TEXT,
  error_message TEXT,
  UNIQUE(buyer_id, product_id)
);

-- Create an index for faster lookups
CREATE INDEX IF NOT EXISTS idx_purchases_buyer_id ON public.purchases(buyer_id);
CREATE INDEX IF NOT EXISTS idx_purchases_product_id ON public.purchases(product_id);

-- Function to handle product purchase
CREATE OR REPLACE FUNCTION public.purchase_product(
  p_product_id UUID,
  p_buyer_id UUID
) 
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_product_status TEXT;
  v_seller_id UUID;
  v_purchase_id UUID;
  v_result JSONB;
BEGIN
  -- Check if product exists and get its status
  SELECT status, owner_id 
  INTO v_product_status, v_seller_id
  FROM public.products 
  WHERE id = p_product_id
  FOR UPDATE; -- Lock the row to prevent race conditions
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Product not found'
    );
  END IF;
  
  -- Check if product is already sold or if purchase already exists
  IF v_product_status = 'sold' OR EXISTS (
    SELECT 1 FROM public.purchases 
    WHERE buyer_id = p_buyer_id AND product_id = p_product_id
  ) THEN
    -- If purchase already exists, return the existing purchase
    SELECT jsonb_build_object(
      'success', true,
      'purchase_id', id,
      'message', 'Purchase already exists',
      'already_purchased', true
    ) INTO v_result
    FROM public.purchases 
    WHERE buyer_id = p_buyer_id AND product_id = p_product_id
    LIMIT 1;
    
    RETURN v_result;
  END IF;
  
  -- Check if user is trying to buy their own product
  IF v_seller_id = p_buyer_id THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'You cannot purchase your own product'
    );
  END IF;
  
  -- Start a transaction
  BEGIN
    -- Create purchase record
    INSERT INTO public.purchases (
      buyer_id,
      product_id,
      status,
      transaction_id
    ) VALUES (
      p_buyer_id,
      p_product_id,
      'completed',
      gen_random_uuid()::TEXT
    )
    RETURNING id INTO v_purchase_id;
    
    -- Update product status to sold
    UPDATE public.products
    SET status = 'sold',
        updated_at = NOW()
    WHERE id = p_product_id;
    
    -- Return success response
    RETURN jsonb_build_object(
      'success', true,
      'purchase_id', v_purchase_id,
      'message', 'Purchase completed successfully'
    );
    
  EXCEPTION WHEN OTHERS THEN
    -- Log the error
    INSERT INTO public.purchases (
      buyer_id,
      product_id,
      status,
      error_message
    ) VALUES (
      p_buyer_id,
      p_product_id,
      'failed',
      SQLERRM
    )
    RETURNING id INTO v_purchase_id;
    
    -- Return error response
    RETURN jsonb_build_object(
      'success', false,
      'purchase_id', v_purchase_id,
      'error', 'Failed to complete purchase: ' || SQLERRM
    );
  END;
END;
$$;

-- Grant necessary permissions
GRANTANT EXECUTE ON FUNCTION public.purchase_product(UUID, UUID) TO authenticated;

-- Add RLS policies if using Row Level Security
ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;

-- Allow users to see their own purchases
CREATE POLICY "Users can view their own purchases"
  ON public.purchases
  FOR SELECT
  USING (auth.uid() = buyer_id);

-- Allow authenticated users to create purchases
CREATE POLICY "Authenticated users can create purchases"
  ON public.purchases
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Allow users to update their own purchases (for status updates, etc.)
CREATE POLICY "Users can update their own purchases"
  ON public.purchases
  FOR UPDATE
  USING (auth.uid() = buyer_id);
