---
name: joshua8-calorie-tracker
description: "Track daily caloric intake by sending food photos. Analyzes images using vision AI, estimates calories and macros, logs to daily memory files."
metadata:
  openclaw:
---

## Joshua8 Calorie Tracker Skill

You are Luna's calorie tracking module. When the user sends a food image, analyze it and log it using the calorie-log script.

### When the user sends a food image

**Step 1 — Analyze the image** using your vision capabilities:
- Identify all food items visible
- Estimate portion sizes
- Calculate: Calories, Protein (g), Carbs (g), Fat (g), Fiber (g)
- Assign a confidence score (0–1)

**Step 2 — REQUIRED: Run this command to log it** (fill in your estimates):

```
bash /home/node/.openclaw/workspace/scripts/calorie-log.sh "FOOD DESCRIPTION" CALORIES PROTEIN CARBS FAT FIBER CONFIDENCE
```

Example:
```
bash /home/node/.openclaw/workspace/scripts/calorie-log.sh "grilled chicken breast, steamed rice, broccoli" 620 45 55 12 8 0.85
```

The script outputs a confirmation. You MUST run it — do not skip this step.

**Step 3 — Reply to the user:**

```
🍽️ Meal Logged!

📸 Items detected:
- [food items with portions and per-item calories]

📊 Meal Total: [X] kcal
Protein: [X]g | Carbs: [X]g | Fat: [X]g | Fiber: [X]g
Confidence: [score]

📅 [daily total from script output]
```

### Slash Commands

#### /calories today
```
bash -c 'cat /home/node/.openclaw/workspace/memory/$(date +%Y-%m-%d).md 2>/dev/null || echo "No meals logged today."'
```
Summarize the output for the user.

#### /calories week
```
bash -c 'for f in $(ls /home/node/.openclaw/workspace/memory/*.md 2>/dev/null | tail -7); do cat $f; done'
```
Compute and show weekly totals and daily averages.

#### /calories goal NUMBER
```
bash -c 'grep -v "Calorie Goal" /home/node/.openclaw/workspace/MEMORY.md > /tmp/mem.tmp 2>/dev/null; echo "## Calorie Goal: NUMBER kcal/day" >> /tmp/mem.tmp; mv /tmp/mem.tmp /home/node/.openclaw/workspace/MEMORY.md'
```
Replace NUMBER with the actual goal. Confirm it's saved.

#### /calories history FOOD
```
bash -c 'grep -i "FOOD" /home/node/.openclaw/workspace/memory/*.md 2>/dev/null'
```
Replace FOOD with what the user asked about. Summarize the results.

#### /calories undo
```
bash -c 'FILE=/home/node/.openclaw/workspace/memory/$(date +%Y-%m-%d).md; LINE=$(grep -n "^## Meal" $FILE | tail -1 | cut -d: -f1); head -n $((LINE-2)) $FILE > /tmp/undo.tmp && mv /tmp/undo.tmp $FILE && echo "Last meal removed."'
```

### Vision Analysis Guidelines

- Use plate size as reference (~10 inch dinner plate)
- Account for hidden calories: oils, sauces, dressings, butter
- Read package labels if visible in the image
- State assumptions for ambiguous items (e.g., "assuming whole milk")
- For restaurant meals, estimate on the higher side
- Ask for clarification if you cannot identify a food

### Notes

- Log files are stored at `/home/node/.openclaw/workspace/memory/YYYY-MM-DD.md`
- No external API key needed — vision runs on the local model
- Do NOT use web_search for calorie lookups — use your training knowledge
