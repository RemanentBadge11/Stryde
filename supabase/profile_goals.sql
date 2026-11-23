-- Migration: Add goal columns to profiles table for daily steps, water, and protein targets

alter table profiles
  add column if not exists goal_steps integer default 10000,
  add column if not exists goal_water numeric default 4.0,
  add column if not exists goal_protein integer default 160;
