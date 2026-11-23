-- Sync Total XP and Available Skill Points Migration
-- Adds cumulative total_xp and available_skill_points columns to profiles table

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS total_xp integer DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS available_skill_points integer DEFAULT 0;

-- Ensure unique constraints for idempotent upserts
CREATE UNIQUE INDEX IF NOT EXISTS user_medals_user_id_medal_id_idx ON user_medals (user_id, medal_id);
CREATE UNIQUE INDEX IF NOT EXISTS skills_user_id_muscle_group_key ON skills (user_id, muscle_group);
