-- Create a function to get purchase history with product details
CREATE OR REPLACE FUNCTION public.get_purchase_history(p_user_id UUID)
RETURNS TABLE (
  id UUID,
  created_at TIMESTAMPTZ,
  product JSONB
)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT 
    p.id,
    p.created_at,
    jsonb_build_object(
      'id', pr.id,
      'name', pr.name,
      'image_url', pr.image_url,
      'price', pr.price
    ) as product
  FROM 
    purchases p
    JOIN products pr ON p.product_id = pr.id
  WHERE 
    p.buyer_id = p_user_id
  ORDER BY 
    p.created_at DESC;
$$;
