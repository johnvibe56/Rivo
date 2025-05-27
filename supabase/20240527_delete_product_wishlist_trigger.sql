-- Function to delete wishlist entries for a product
-- Can be called directly with a product_id or used in a trigger
create or replace function public.delete_product_wishlists(p_product_id uuid default null)
returns void
language plpgsql
security definer
as $$
begin
  if p_product_id is not null then
    -- Called directly with a product_id
    delete from public.wishlist where product_id = p_product_id;
  elsif TG_OP = 'DELETE' then
    -- Called from a trigger
    delete from public.wishlist where product_id = OLD.id;
  end if;
  
  return;
end;
$$;

-- Drop the existing trigger if it exists
drop trigger if exists on_product_delete on public.products;

-- Create the trigger
create trigger on_product_delete
after delete on public.products
for each row
execute function public.delete_product_wishlists();