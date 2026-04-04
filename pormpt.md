## Flutter + Supabase | Production-Ready Native App

---

## ROLE & CONTEXT

You are a senior Flutter engineer and UI/UX specialist. Build a **production-ready, native mobile expense tracker app** using Flutter (latest stable) and Supabase as the backend. The app targets Gen Z users — it must feel smooth, opinionated, visually alive, and genuinely fun to use. Think of the personality as: *a fintech app that actually has a sense of humor about your spending habits.*

Do not generate placeholder UI or skeleton screens. Every screen must be **fully functional, pixel-polished, and wired to real data.**

---

## TECH STACK

```
Frontend  : Flutter (latest stable) — Dart
Backend   : Supabase (Auth + PostgreSQL + Realtime + Storage)
State     : Riverpod (flutter_riverpod + riverpod_annotation) with code generation
Navigation: GoRouter
Charts    : fl_chart
Animations: flutter_animate (primary), Lottie (emoji reactions)
Storage   : shared_preferences (local settings cache)
DI        : riverpod
HTTP      : Supabase Flutter SDK (supabase_flutter)
Utils     : intl, freezed, json_serializable, uuid
```

### pubspec.yaml dependencies (include all of these)
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.0
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^13.2.1
  fl_chart: ^0.68.0
  flutter_animate: ^4.5.0
  lottie: ^3.1.2
  intl: ^0.19.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  shared_preferences: ^2.2.3
  uuid: ^4.4.0
  collection: ^1.18.0

dev_dependencies:
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
```

---

## SUPABASE SCHEMA

### Authentication
Use Supabase Auth with **email + password** and **Google OAuth**. On first login, auto-create a `user_settings` row for the user.

### Table: `expenses`
```sql
create table public.expenses (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  amount        numeric(12, 2) not null check (amount > 0),
  category      text not null check (category in (
                  'food', 'delivery', 'travel', 'shopping',
                  'entertainment', 'health', 'bills', 'other')),
  payment_method text not null check (payment_method in ('upi', 'card', 'cash')),
  note          text,
  spent_at      timestamptz not null default now(),
  created_at    timestamptz not null default now(),
  is_deleted    boolean not null default false
);

-- Index for fast daily/monthly queries
create index idx_expenses_user_date on public.expenses(user_id, spent_at);

-- RLS
alter table public.expenses enable row level security;
create policy "Users see own expenses" on public.expenses
  for all using (auth.uid() = user_id);
```

### Table: `user_settings`
```sql
create table public.user_settings (
  user_id       uuid primary key references auth.users(id) on delete cascade,
  daily_limit   numeric(12, 2) not null default 2000,
  currency      text not null default 'INR',
  display_name  text,
  avatar_url    text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

alter table public.user_settings enable row level security;
create policy "Users manage own settings" on public.user_settings
  for all using (auth.uid() = user_id);
```

### Supabase Edge Function: `daily-reset` (cron)
```typescript
// runs at midnight IST (18:30 UTC) — no data deleted, just a hook for future notifications
// Reset is implicit: app filters expenses by date, no actual reset needed server-side
```

### Enable Realtime on `expenses` table
```sql
alter publication supabase_realtime add table expenses;
```

---

## FOLDER STRUCTURE

```
lib/
├── main.dart
├── app/
│   ├── app.dart                  # MaterialApp.router + GoRouter setup
│   ├── router.dart               # All routes defined here
│   └── theme/
│       ├── app_theme.dart        # ThemeData (dark + light)
│       ├── app_colors.dart       # Color constants
│       └── app_text_styles.dart  # TextStyle constants
├── core/
│   ├── constants/
│   │   ├── categories.dart       # Category enum + metadata
│   │   └── payment_methods.dart  # PaymentMethod enum + metadata
│   ├── extensions/
│   │   ├── date_ext.dart         # DateTime helpers
│   │   └── num_ext.dart          # Currency formatting
│   └── utils/
│       └── emoji_reactor.dart    # Budget % → emoji + message + color logic
├── data/
│   ├── models/
│   │   ├── expense.dart          # Freezed model
│   │   └── user_settings.dart    # Freezed model
│   └── repositories/
│       ├── expense_repository.dart
│       └── settings_repository.dart
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   └── providers/
│   │       └── auth_provider.dart
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   ├── widgets/
│   │   │   ├── budget_header.dart      # Emoji + limit + progress bar
│   │   │   ├── emoji_reactor_widget.dart
│   │   │   ├── spend_progress_bar.dart
│   │   │   └── expense_tile.dart
│   │   └── providers/
│   │       └── home_provider.dart
│   ├── add_expense/
│   │   ├── screens/
│   │   │   └── add_expense_sheet.dart  # Bottom sheet, 3 steps
│   │   ├── widgets/
│   │   │   ├── step_amount.dart
│   │   │   ├── step_category.dart
│   │   │   └── step_method_note.dart
│   │   └── providers/
│   │       └── add_expense_provider.dart
│   ├── stats/
│   │   ├── screens/
│   │   │   └── stats_screen.dart
│   │   ├── widgets/
│   │   │   ├── monthly_summary_card.dart
│   │   │   ├── category_bar_chart.dart
│   │   │   ├── monthly_bar_chart.dart  # fl_chart
│   │   │   └── method_breakdown.dart
│   │   └── providers/
│   │       └── stats_provider.dart
│   └── settings/
│       ├── screens/
│       │   └── settings_screen.dart
│       └── providers/
│           └── settings_provider.dart
└── shared/
    └── widgets/
        ├── primary_button.dart
        ├── glass_card.dart
        └── step_indicator.dart
```

---

## DESIGN SYSTEM

### Theme
- **Background**: `#08080F` (deep dark)
- **Surface**: `rgba(255,255,255,0.04)` with `rgba(255,255,255,0.08)` border
- **Accent Primary**: `#7C6BFF` (purple)
- **Accent Secondary**: `#9D4EDD`
- **Success**: `#10B981`
- **Warning**: `#F59E0B`
- **Danger**: `#EF4444`
- **Text Primary**: `#F0F0FA`
- **Text Muted**: `rgba(240,240,250,0.42)`

```dart
// app_colors.dart
static const background   = Color(0xFF08080F);
static const surface      = Color(0xFF0E0E1A);
static const surfaceBorder = Color(0x14FFFFFF); // 8% white
static const accent        = Color(0xFF7C6BFF);
static const accentSecondary = Color(0xFF9D4EDD);
static const success       = Color(0xFF10B981);
static const warning       = Color(0xFFF59E0B);
static const danger        = Color(0xFFEF4444);
static const textPrimary   = Color(0xFFF0F0FA);
static const textMuted     = Color(0x6BF0F0FA); // 42% white
```

### Typography
Use **Plus Jakarta Sans** via `google_fonts` package.
```dart
// Weights used: w400, w600, w700, w800, w900
// Display: 40sp w900 (amount input)
// Heading: 22sp w800
// Body: 15sp w400
// Label: 11sp w700 letterSpacing 0.1 (uppercase caps)
// Tag/Badge: 11sp w700
```

### Spacing & Radius
```dart
// Radius
const radiusSm  = 10.0;
const radiusMd  = 14.0;
const radiusLg  = 18.0;
const radiusXl  = 22.0;
const radiusFull = 99.0;

// Padding
const pagePadding = EdgeInsets.symmetric(horizontal: 20.0);
const cardPadding = EdgeInsets.all(16.0);
```

---

## CATEGORY CONSTANTS

```dart
enum ExpenseCategory {
  food, delivery, travel, shopping,
  entertainment, health, bills, other
}

class CategoryMeta {
  final String label;
  final String emoji;
  final Color color;
}

// Map each category:
// food         → '🍔' → Color(0xFFFF6B6B)
// delivery     → '🛵' → Color(0xFFFF8A65)
// travel       → '✈️' → Color(0xFF64B5F6)
// shopping     → '🛍️' → Color(0xFFCE93D8)
// entertainment→ '🎮' → Color(0xFF4DB6AC)
// health       → '💊' → Color(0xFF81C784)
// bills        → '💡' → Color(0xFFFFD54F)
// other        → '✨' → Color(0xFFF06292)
```

---

## EMOJI REACTOR LOGIC

```dart
// core/utils/emoji_reactor.dart
class EmojiReaction {
  final String emoji;
  final String message;
  final Color color;
}

EmojiReaction getReaction(double percentSpent) {
  if (percentSpent == 0)    return EmojiReaction('😴', 'nothing spent yet~',       Color(0xFF6B7280));
  if (percentSpent <= 15)   return EmojiReaction('😎', 'slay, you\'re saving fr',  Color(0xFF10B981));
  if (percentSpent <= 35)   return EmojiReaction('😊', 'vibing, all good bestie',  Color(0xFF22C55E));
  if (percentSpent <= 55)   return EmojiReaction('🙂', 'mid spend, keep it chill', Color(0xFFEAB308));
  if (percentSpent <= 70)   return EmojiReaction('😬', 'getting spenny ngl',       Color(0xFFF59E0B));
  if (percentSpent <= 85)   return EmojiReaction('😰', 'bro stop fr fr',           Color(0xFFF97316));
  if (percentSpent <= 100)  return EmojiReaction('🤯', 'you absolutely cooked rn', Color(0xFFEF4444));
  return                         EmojiReaction('💀', 'budget? never heard of it', Color(0xFFDC2626));
}
```

---

## SCREENS — DETAILED SPEC

---

### 1. AUTH SCREENS (`/login`, `/signup`)

- Clean dark card centered on background
- Email + password fields with animated focus borders (accent color on focus)
- Google OAuth button with official branding
- On success → navigate to `/home` and create `user_settings` row if not exists
- Show loading state on button while authenticating
- Inline error messages (no dialogs)

---

### 2. HOME SCREEN (`/home`)

#### Layout (single `CustomScrollView` with `SliverAppBar`)

**Sticky Header — `BudgetHeader` widget:**
- Top-left: "Daily Limit" label + tappable limit value (tap → inline `TextField` edit mode)
- Top-right: Large emoji (56sp) that **animates with `flutter_animate`** on every change:
  - `.scale(begin: 0.6, end: 1.0).shake(hz: 3)` when percentage crosses a threshold
  - Subtle `glow` shadow color matches `EmojiReaction.color`, animated with `AnimatedContainer`
- Below: spend progress bar
  - `AnimatedFractionallySizedBox` for smooth width transition (600ms `Curves.elasticOut`)
  - Gradient: green → amber → red depending on `percentSpent`
  - Glow: `BoxShadow` color = `EmojiReaction.color` with 0.35 opacity
  - Row below bar: left = `ed.message` in `ed.color`, right = `₹spent / ₹limit`

**Body — Today's Expenses List:**
- Section header: "Today" label (left) + transaction count (right)
- Empty state: floating jar emoji `🫙` with `flutter_animate` `.animate(onPlay: (c)=>c.repeat()).moveY(begin:0, end:-6, duration:2.s)`
- `AnimatedList` or `ListView` with staggered `slideUp + fadeIn` on initial build
- Each `ExpenseTile`:
  - Left: 46×46 rounded square with category color bg + emoji
  - Middle: amount (bold) + category chip + payment method emoji
  - Optional note in muted text below
  - Right: time string + delete button (red on tap)
  - Dismissible with `DismissDirection.endToStart` for swipe-to-delete

**Bottom Bar (persistent):**
- `SafeArea` + `BlurredBottomBar` widget with `BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20))`
- Left: "📊 Stats" ghost button → `/stats`
- Right: "+ Add Expense" filled gradient button → shows `AddExpenseSheet` as modal bottom sheet

---

### 3. ADD EXPENSE SHEET (`AddExpenseSheet`)

Show as `showModalBottomSheet` with `isScrollControlled: true`, `useSafeArea: true`, `backgroundColor: Color(0xFF08080F)`.

#### Internal navigation: 3 steps with `PageView` (no swipe, programmatic only)

**Step indicator:** 3 animated segment pills at top. Active = accent color with glow, past = 50% accent, future = surface.

---

**Step 0 — Amount**
- Giant `₹` prefix + `TextField` with `fontSize: 44, fontWeight: w900`
- Keyboard type: `numberWithOptions(decimal: true)`
- Auto-focus on open
- Quick-tap chips: ₹50, ₹100, ₹200, ₹500, ₹1000, ₹2000
  - Tapping sets the field value + triggers `HapticFeedback.lightImpact()`
- "Next →" button disabled until valid amount > 0

**Step 1 — Category**
- Label: "where'd the money go?"
- 4-column `GridView` of category buttons
  - Each: emoji (28sp) + label (10sp) in a rounded card
  - Selected: category color bg tint + border + `scale(1.06)` with `AnimatedScale`
  - `HapticFeedback.selectionClick()` on select
- Back + Next buttons

**Step 2 — Payment Method + Note**
- 3-column row of method cards (UPI / Card / Cash)
  - Each: emoji (30sp) + label + sub-description
  - Selected: accent tint + border + scale up
- Optional note `TextField` with hint "what was this for? 👀"
- Summary card showing: category emoji + formatted amount + "category via method · note"
- "✓ Log it" green gradient button
  - On tap: call `addExpense()` provider method → `HapticFeedback.heavyImpact()` → show success overlay → dismiss sheet → home refreshes

**Success overlay (inside sheet):**
- `AnimatedOpacity` black overlay + 🎉 emoji with `.scale().shake()` + "logged, no cap ✓" in green
- Auto-dismiss after 1.5 seconds

---

### 4. STATS SCREEN (`/stats`)

Two tabs: **This Month** | **This Year** — using `TabController`, no `TabBar` widget, custom animated pill tabs.

#### Monthly Tab
- Hero card: month name + total + transaction count + avg/day + "vs limit" badge (green/red)
- **Category breakdown** (`fl_chart` `BarChart` or animated `LinearProgressIndicator` list):
  - Each category: emoji + label + amount + percentage of total
  - Animated fill bar (category color) from 0 to width on tab load
  - Sorted by total descending
- **Payment method split**: 3 equal cards with emoji + total + times used
- **Daily spend sparkline** (`fl_chart` `LineChart`): x = days of month, y = daily spend, horizontal line = daily limit

#### Yearly Tab
- Hero card: year total + transaction count + avg/month
- **Monthly bar chart** (`fl_chart` `BarChart`):
  - 12 bars, current month highlighted in accent gradient
  - Horizontal limit line across all bars
  - Animate bars growing from bottom on mount
- **Top categories this year**: same bar format as monthly
- **Year-over-year note**: placeholder "📊 More years coming soon"

#### Future scope callout card (bottom of both tabs):
```
🔮 coming soon
Auto-detect UPI spends • SMS parsing • Budget goals • CSV export • Recurring expenses
```

---

### 5. SETTINGS SCREEN (`/settings`)

- Avatar + display name (editable)
- Daily limit (navigates back to home edit mode or inline edit here)
- Currency selector (INR default, USD, EUR, GBP)
- Appearance toggle (Dark / System)
- Notification toggle (placeholder for v2 UPI detection)
- Sign out button
- App version footer

---

## PROVIDERS (Riverpod)

```dart
// expenses_provider.dart
@riverpod
class ExpensesNotifier extends _$ExpensesNotifier {
  // Streams from Supabase Realtime for live updates
  // Methods: addExpense(), deleteExpense(), fetchTodayExpenses()
  // fetchMonthExpenses(DateTime month), fetchYearExpenses(int year)
}

// settings_provider.dart
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  // Methods: updateDailyLimit(double), updateCurrency(String)
  // Optimistic update: update local state → Supabase upsert
}

// stats_provider.dart
@riverpod
Future<StatsData> monthlyStats(MonthlyStatsRef ref, DateTime month) async {
  // Aggregation: totalByCategory, totalByMethod, dailyTotals[], grandTotal
}

@riverpod
Future<StatsData> yearlyStats(YearlyStatsRef ref, int year) async {
  // monthlyTotals[], totalByCategory, grandTotal
}
```

---

## DATA MODELS (Freezed)

```dart
@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String userId,
    required double amount,
    required ExpenseCategory category,
    required PaymentMethod paymentMethod,
    String? note,
    required DateTime spentAt,
    required DateTime createdAt,
  }) = _Expense;
  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    required String userId,
    required double dailyLimit,
    required String currency,
    String? displayName,
    String? avatarUrl,
  }) = _UserSettings;
  factory UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);
}
```

---

## ANIMATIONS SPEC

Use `flutter_animate` for all transitions. Never use raw `AnimationController` unless absolutely necessary.

| Trigger | Widget | Animation |
|---|---|---|
| Screen mount | Expense tiles | `.animate(delay: i*40.ms).slideY(begin:0.3).fadeIn(duration:300.ms)` |
| Budget % changes threshold | Emoji widget | `.animate().scale(begin:0.6).shake(hz:3, duration:500.ms)` |
| Category selected | Category card | `AnimatedScale(scale: selected ? 1.06 : 1.0, duration: 150ms)` |
| Expense added | Success overlay | `.animate().scale(begin:0.5).fadeIn()` |
| Progress bar fill | Progress bar | `AnimatedFractionallySizedBox(duration: 600ms, curve: Curves.elasticOut)` |
| Stats bars | fl_chart bars | `BarChartData` with `barTouchData` + `fl_chart`'s built-in animation |
| Empty state | Jar emoji | `.animate(onPlay:(c)=>c.repeat()).moveY(begin:0,end:-6,duration:2000.ms).then().moveY(begin:-6,end:0,duration:2000.ms)` |
| Delete | ExpenseTile | `Dismissible` + `AnimatedOpacity` fade out |
| Add sheet open | Sheet drag handle | Sheet uses `DraggableScrollableSheet` |

**Glow effect on emoji:**
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 600),
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: emojiReaction.color.withOpacity(percentSpent > 60 ? 0.45 : 0.0),
        blurRadius: 24,
        spreadRadius: 4,
      ),
    ],
  ),
  child: Text(emojiReaction.emoji, style: TextStyle(fontSize: 56)),
)
```

---

## SUPABASE REALTIME

Subscribe to the `expenses` channel on home screen mount. On `INSERT` / `DELETE` events matching the current user's `user_id` and today's date, **invalidate the expenses provider** to trigger a rebuild. This enables future multi-device sync.

```dart
supabase.channel('expenses_realtime')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'expenses',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'user_id',
      value: supabase.auth.currentUser!.id,
    ),
    callback: (payload) => ref.invalidate(expensesNotifierProvider),
  )
  .subscribe();
```

---

## FUTURE SCOPE (scaffold now, implement later)

### UPI Auto-Detection
- Add a `UpiDetectionService` class (empty stub) with method `listenForUpiSms()`
- Uses `telephony` package to read SMS matching patterns: `"debited"`, `"UPI"`, `"Rs."`, `"INR"`
- When detected: parse amount + merchant name → show `UpiConfirmationBottomSheet` with pre-filled amount and a note field
- User taps "Yes, add it" → calls normal `addExpense()` flow
- Add permission request in `AndroidManifest.xml` (commented out, ready to enable)

### Budget Goals
- `budget_goals` table scaffold (category, monthly_limit, user_id)
- `GoalProgressWidget` stub in stats screen

### Push Notifications
- Supabase Edge Function trigger on midnight to send "You have ₹X left today" via FCM
- Add `firebase_messaging` to pubspec (commented, ready)

---

## CODE QUALITY REQUIREMENTS

- All async operations in repositories must use `try/catch` with typed `PostgrestException` handling
- No `BuildContext` usage across async gaps — use `mounted` checks
- `const` constructors everywhere possible
- All colors, text styles, and spacing via theme/constants — zero magic numbers in UI files
- `GoRouter` redirect guards: unauthenticated users always redirect to `/login`
- Supabase client initialized in `main.dart` before `runApp()`, accessed via `Supabase.instance.client`
- Use `ConsumerStatefulWidget` only when local animation controllers are needed; prefer `ConsumerWidget` + `ref.watch` for everything else

---

## DELIVERABLE CHECKLIST

Generate complete, runnable code for:

- [ ] `main.dart` with Supabase init + Riverpod `ProviderScope`
- [ ] Full `AppTheme` with dark theme only for now
- [ ] All data models with `freezed` + `json_serializable`
- [ ] Both Supabase repositories (`expenses`, `settings`)
- [ ] All Riverpod providers with code-gen annotations
- [ ] All 5 screens fully built (auth, home, add_expense sheet, stats, settings)
- [ ] All reusable widgets
- [ ] `GoRouter` config with auth redirect guard
- [ ] SQL migration file for both tables + RLS policies
- [ ] `README.md` with setup steps (Supabase project config, env vars, run instructions)

---

## CONSTRAINTS

- Target: **iOS and Android** (no web)
- Minimum SDK: Android 21 / iOS 14
- All amounts in **Indian Rupees (₹)** by default, formatted with `NumberFormat.currency(locale: 'en_IN', symbol: '₹')`
- Daily limit resets automatically at midnight — no server-side job needed; filter by `DATE(spent_at) = CURRENT_DATE` in queries
- Offline-first for reads: cache today's expenses in `SharedPreferences` as JSON fallback when Supabase is unreachable
- All expense `spent_at` timestamps stored in UTC, displayed in device local time