import 'package:supabase_flutter/supabase_flutter.dart';

/// Returns the initialized app-wide Supabase client.
///
/// `main()` always initializes Supabase before building the app. Returning
/// `null` here keeps isolated provider and widget tests—which intentionally do
/// not run `main()`—from failing on Supabase's initialization assertion.
SupabaseClient? get supabaseClientOrNull {
  try {
    return Supabase.instance.client;
  } on AssertionError {
    return null;
  } on StateError {
    return null;
  }
}
