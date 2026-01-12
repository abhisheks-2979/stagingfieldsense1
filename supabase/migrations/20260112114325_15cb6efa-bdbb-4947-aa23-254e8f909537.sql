-- Add foreign key constraint to social_post_attachments
ALTER TABLE public.social_post_attachments
ADD CONSTRAINT social_post_attachments_post_id_fkey
FOREIGN KEY (post_id) REFERENCES public.social_posts(id) ON DELETE CASCADE;