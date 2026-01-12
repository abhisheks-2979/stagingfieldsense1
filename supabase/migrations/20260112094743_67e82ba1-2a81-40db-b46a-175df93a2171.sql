-- Create storage bucket for attendance photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('attendance-photos', 'attendance-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload their own attendance photos
CREATE POLICY "Users can upload own attendance photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'attendance-photos' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to update their own attendance photos
CREATE POLICY "Users can update own attendance photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'attendance-photos' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to delete their own attendance photos
CREATE POLICY "Users can delete own attendance photos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'attendance-photos' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow public read access to attendance photos
CREATE POLICY "Public read access for attendance photos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'attendance-photos');