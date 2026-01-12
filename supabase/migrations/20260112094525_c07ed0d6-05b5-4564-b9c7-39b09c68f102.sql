-- Create storage bucket for employee photos (used by profile photo upload)
INSERT INTO storage.buckets (id, name, public)
VALUES ('employee-photos', 'employee-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload their own photos
CREATE POLICY "Users can upload own employee photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'employee-photos' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to update their own photos
CREATE POLICY "Users can update own employee photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'employee-photos' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to delete their own photos
CREATE POLICY "Users can delete own employee photos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'employee-photos' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow public read access to employee photos
CREATE POLICY "Public read access for employee photos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'employee-photos');