# Joshua8 OpenClaw Calorie Tracker

An [OpenClaw](https://openclaw.ai) skill for tracking daily caloric intake using vision AI.

## Features

- Send a food photo → Charlotte analyzes it and logs calories + macros
- UPC barcode lookup for packaged foods via [UPCItemDB](https://upcitemdb.com) (free, no key)
- Daily and weekly summaries
- Calorie goal tracking
- Food history search

## Slash Commands

- `/calories today` — today's full log and totals
- `/calories week` — 7-day summary with daily bar chart
- `/calories goal 2000` — set daily calorie goal
- `/calories history chicken` — search past meals
- `/calories undo` — remove last logged meal

## Installation

Copy `SKILL.md` to `data/workspace/skills/joshua8-calorie-tracker/SKILL.md` in your OpenClaw deployment.

Copy `scripts/calorie-log.sh` and `scripts/upc-lookup.sh` to `data/workspace/scripts/` and make them executable.

Also add to `AGENTS.md` Skill Quick Reference:

```
**Calorie tracking / Joshua8 Calorie Tracker** (food photo or "log this meal"): ALWAYS run `bash /home/node/.openclaw/workspace/scripts/calorie-log.sh "food description" CALORIES PROTEIN CARBS FAT FIBER CONFIDENCE` — do this BEFORE replying.
```

## License

MIT

