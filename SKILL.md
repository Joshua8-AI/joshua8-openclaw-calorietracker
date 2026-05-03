---
name: joshua8-calorie-tracker
description: "Calorie tracking via food photos — vision AI estimates macros and logs to daily file."
metadata:
  openclaw:
---

# Calorie Tracker

When the user sends a food image: identify items, estimate portions and macros (calories, protein, carbs, fat, fiber) with a confidence score (0–1), then log:

```
bash /home/node/.openclaw/workspace/scripts/calorie-log.sh "<food description>" <kcal> <protein> <carbs> <fat> <fiber> <confidence>
```

Reply with items detected, totals, and the daily total printed by the script.

## Slash commands

| Command | Action |
|---|---|
| `/calories today` | `cat /home/node/.openclaw/workspace/memory/$(date +%Y-%m-%d).md` — summarize |
| `/calories week` | concat last 7 daily files, compute totals + daily averages |
| `/calories goal NUMBER` | replace `## Calorie Goal:` line in `MEMORY.md` |
| `/calories history FOOD` | `grep -i "FOOD" /home/node/.openclaw/workspace/memory/*.md` — summarize |
| `/calories undo` | strip the last `## Meal` block from today's file |

## Vision notes

- Use plate size (~10″) for scale. Account for hidden oils/sauces/butter.
- Read package labels if visible; state assumptions for ambiguous items.
- Restaurant meals: estimate high. Ask if you can't identify a food.
- Vision runs locally — do NOT use web_search for calorie lookups.
