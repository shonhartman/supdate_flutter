/// Supabase project URL and anon key.
///
/// These are supplied at build time via Dart compile-time variables so they
/// are never committed to version control.
///
/// **Option 1 – config file (recommended)**
/// 1. Copy `config.json.example` to `config.json`.
/// 2. Fill in your project URL and anon key from Supabase dashboard → Settings → API.
/// 3. Run: `flutter run --dart-define-from-file=config.json`
///    (or add the same flag in your IDE run configuration.)
///
/// **Option 2 – command line**
/// `flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key`
///
/// Ensure `config.json` is listed in `.gitignore` and never commit it.

const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '',
);

const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '',
);

/// Throws [ArgumentError] if URL or anon key are missing (e.g. not provided via --dart-define).
void requireSupabaseConfig() {
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw ArgumentError(
      'SUPABASE_URL and SUPABASE_ANON_KEY must be set. '
      'Use --dart-define-from-file=config.json or --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
    );
  }
}
