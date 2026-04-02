#!/bin/bash
# Usage: calorie-log.sh "food description" calories protein carbs fat fiber confidence
# Example: calorie-log.sh "grilled chicken, rice, broccoli" 620 45 55 12 8 0.85

FOOD="$1"
CALORIES="$2"
PROTEIN="$3"
CARBS="$4"
FAT="$5"
FIBER="${6:-0}"
CONFIDENCE="${7:-0.8}"

if [ -z "$FOOD" ] || [ -z "$CALORIES" ]; then
  echo "Usage: calorie-log.sh \"food description\" calories protein carbs fat [fiber] [confidence]"
  exit 1
fi

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
FILE="/home/node/.openclaw/workspace/memory/${DATE}.md"

# Count existing meals for meal number
MEAL_NUM=$(grep -c "^## Meal" "$FILE" 2>/dev/null || echo 0)
MEAL_NUM=$((MEAL_NUM + 1))

# Append meal entry
cat >> "$FILE" << EOF

## Meal ${MEAL_NUM} — ${TIME}
- **Items**: ${FOOD}
- **Calories**: ${CALORIES} kcal
- **Protein**: ${PROTEIN}g | **Carbs**: ${CARBS}g | **Fat**: ${FAT}g | **Fiber**: ${FIBER}g
- **Confidence**: ${CONFIDENCE}
EOF

# Compute running daily totals
TOTAL_CAL=$(grep -oP '(?<=\*\*Calories\*\*: )\d+' "$FILE" | awk '{s+=$1} END {print s}')
TOTAL_PRO=$(grep -oP '(?<=\*\*Protein\*\*: )\d+' "$FILE" | awk '{s+=$1} END {print s}')
TOTAL_CARB=$(grep -oP '(?<=Carbs\*\*: )\d+' "$FILE" | awk '{s+=$1} END {print s}')
TOTAL_FAT=$(grep -oP '(?<=Fat\*\*: )\d+' "$FILE" | awk '{s+=$1} END {print s}')

echo "✅ Logged meal ${MEAL_NUM} for ${DATE}"
echo "   ${FOOD}: ${CALORIES} kcal (P:${PROTEIN}g C:${CARBS}g F:${FAT}g)"
echo "   Daily total: ${TOTAL_CAL} kcal across ${MEAL_NUM} meal(s)"
