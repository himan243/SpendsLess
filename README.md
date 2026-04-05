# SpendsLess

SpendsLess is a personal expense-tracking app built with Flutter. It helps users log daily spending, monitor budget limits, and understand where money is going through simple stats and category breakdowns.

## What This App Does

SpendsLess is designed for fast, everyday money tracking with a clean and low-friction workflow.

Core capabilities:
- Add and manage expense entries (amount, category, payment method, note, date/time)
- Set a budget as either:
	- Daily limit, or
	- Monthly limit with dynamic daily rollover logic
- View current spending progress against budget
- Analyze spending patterns in stats (month/year views, category filter, transaction logs)
- Keep everything local for private, offline-first usage

## Monthly Budget Behavior

When using monthly mode, SpendsLess calculates a dynamic daily limit from your remaining monthly budget and remaining days in the month.

This means:
- If you spend less than today's share, the extra carries forward and tomorrow's limit increases
- If you overspend earlier in the month, upcoming daily limits decrease

This gives a realistic pacing model instead of a fixed daily split.

## Main Uses

SpendsLess is useful for:
- Daily personal budgeting
- Preventing small recurring overspending
- Building awareness of spending by category (food, travel, shopping, etc.)
- Month-end budget control with adaptive daily targets
- Quick review of transactions without exporting data to external tools

## Target Audience

SpendsLess is built for people who want practical budget control without complex finance software.

Best suited for:
- Students managing limited monthly allowances
- Working professionals tracking day-to-day discretionary spending
- Anyone trying to reduce unnecessary expenses through habit tracking
- Privacy-conscious users who prefer local storage over cloud-first personal finance apps

## Platform

- Flutter mobile app
- Android support (primary tested flow)

## Project Status

This is an actively evolving app with ongoing improvements to budgeting logic, stats UX, and overall usability.
