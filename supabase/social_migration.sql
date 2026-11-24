-- Migration: Social Network System for Stryde
-- Scope: Activity-based fitness network (Follows, Activity Feed, Immutable Workout Snapshots, Rank Promotions)

-- 1. Ensure case-insensitive username uniqueness on profiles
CREATE UNIQUE INDEX IF NOT EXISTS profiles_username_lower_idx 
    ON public.profiles (lower(username)) 
    WHERE username IS NOT NULL;

CREATE INDEX IF NOT EXISTS profiles_username_search_idx 
    ON public.profiles (lower(username));

-- 2. Follows table
CREATE TABLE IF NOT EXISTS public.follows (
    follower_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    following_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
    PRIMARY KEY (follower_id, following_id),
    CONSTRAINT follows_no_self_follow CHECK (follower_id != following_id)
);

CREATE INDEX IF NOT EXISTS follows_follower_id_idx ON public.follows (follower_id);
CREATE INDEX IF NOT EXISTS follows_following_id_idx ON public.follows (following_id);

-- 3. Social Posts table (Activity-only: workout completions and rank promotions)
CREATE TABLE IF NOT EXISTS public.social_posts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type text NOT NULL CHECK (type IN ('workout', 'rank_up')),
    workout_id text NULL,
    rank_name text NULL,
    data jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Idempotency constraints to prevent duplicate posts
CREATE UNIQUE INDEX IF NOT EXISTS social_posts_user_workout_idx 
    ON public.social_posts (user_id, workout_id) 
    WHERE workout_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS social_posts_user_rank_idx 
    ON public.social_posts (user_id, rank_name) 
    WHERE rank_name IS NOT NULL;

CREATE INDEX IF NOT EXISTS social_posts_user_id_idx ON public.social_posts (user_id);
CREATE INDEX IF NOT EXISTS social_posts_created_at_idx ON public.social_posts (created_at DESC);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_posts ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies for follows
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'follows' AND policyname = 'Follows viewable by authenticated users'
    ) THEN
        CREATE POLICY "Follows viewable by authenticated users"
            ON public.follows FOR SELECT
            TO authenticated
            USING (true);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'follows' AND policyname = 'Users can follow others'
    ) THEN
        CREATE POLICY "Users can follow others"
            ON public.follows FOR INSERT
            TO authenticated
            WITH CHECK ((select auth.uid()) = follower_id AND follower_id != following_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'follows' AND policyname = 'Users can unfollow or remove followers'
    ) THEN
        CREATE POLICY "Users can unfollow or remove followers"
            ON public.follows FOR DELETE
            TO authenticated
            USING ((select auth.uid()) = follower_id OR (select auth.uid()) = following_id);
    END IF;
END $$;

-- 6. RLS Policies for social_posts
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'social_posts' AND policyname = 'Social posts viewable by authenticated users'
    ) THEN
        CREATE POLICY "Social posts viewable by authenticated users"
            ON public.social_posts FOR SELECT
            TO authenticated
            USING (true);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'social_posts' AND policyname = 'Users can create their own social posts'
    ) THEN
        CREATE POLICY "Users can create their own social posts"
            ON public.social_posts FOR INSERT
            TO authenticated
            WITH CHECK ((select auth.uid()) = user_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'social_posts' AND policyname = 'Users can delete their own social posts'
    ) THEN
        CREATE POLICY "Users can delete their own social posts"
            ON public.social_posts FOR DELETE
            TO authenticated
            USING ((select auth.uid()) = user_id);
    END IF;
END $$;

-- 7. Helper functions
-- Check username availability (case-insensitive)
CREATE OR REPLACE FUNCTION public.check_username_available(check_username text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF check_username IS NULL OR length(trim(check_username)) < 3 THEN
        RETURN false;
    END IF;
    RETURN NOT EXISTS (
        SELECT 1 FROM public.profiles WHERE lower(username) = lower(trim(check_username))
    );
END;
$$;

-- Get social counts for profile
CREATE OR REPLACE FUNCTION public.get_profile_social_stats(target_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
    followers_count integer;
    following_count integer;
BEGIN
    SELECT count(*) INTO followers_count FROM public.follows WHERE following_id = target_user_id;
    SELECT count(*) INTO following_count FROM public.follows WHERE follower_id = target_user_id;
    RETURN jsonb_build_object(
        'followers_count', followers_count,
        'following_count', following_count
    );
END;
$$;

-- 8. Explicit Permissions Grant
GRANT SELECT, INSERT, DELETE ON public.follows TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.social_posts TO authenticated;
GRANT EXECUTE ON FUNCTION public.check_username_available(text) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_profile_social_stats(uuid) TO authenticated;
