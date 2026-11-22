-- Patch 2 Migration: Themes, Profile Customization, and Medals System

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS theme_mode text DEFAULT 'dark';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS accent_color text DEFAULT '#FFFFFF';

-- Medals table
CREATE TABLE IF NOT EXISTS user_medals (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    medal_id text NOT NULL,
    unlocked_at timestamptz DEFAULT now()
);

ALTER TABLE user_medals ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'user_medals' AND policyname = 'Users can manage own medals'
    ) THEN
        CREATE POLICY "Users can manage own medals" ON user_medals
            FOR ALL USING (auth.uid() = user_id)
            WITH CHECK (auth.uid() = user_id);
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS user_medals_user_id_medal_id_idx ON user_medals (user_id, medal_id);

-- Storage bucket for avatars
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Public Access'
    ) THEN
        CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Authenticated users can upload avatars'
    ) THEN
        CREATE POLICY "Authenticated users can upload avatars" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Authenticated users can update avatars'
    ) THEN
        CREATE POLICY "Authenticated users can update avatars" ON storage.objects FOR UPDATE USING (bucket_id = 'avatars' AND auth.role() = 'authenticated');
    END IF;
END $$;
