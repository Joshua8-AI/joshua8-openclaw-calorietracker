#!/bin/bash
# UPC Lookup Script - Query UPC ItemDB API for product info with nutritional integration
# Usage: ./upc-lookup.sh <UPC_CODE> [calories] [protein] [carbs] [fat] [fiber] [confidence]
# Example: ./upc-lookup.sh 1356232050
# Example with logging: ./upc-lookup.sh 1356232050 320 4 48 14 0 0.80

UPC_CODE="$1"
CALORIES="$2"
PROTEIN="$3"
CARBS="$4"
FAT="$5"
FIBER="$6"
CONFIDENCE="$7"

if [ -z "$UPC_CODE" ]; then
    echo "Usage: $0 <UPC_CODE> [calories] [protein] [carbs] [fat] [fiber] [confidence]"
    echo "Example: $0 1356232050"
    echo "With logging: $0 1356232050 320 4 48 14 0 0.80"
    exit 1
fi

# Clean the UPC code (remove spaces, dashes)
UPC_CODE=$(echo "$UPC_CODE" | tr -d ' -')

# Try multiple UPC formats
UPC_FORMATS=(
    "$UPC_CODE"
    "0$UPC_CODE"
    "1$UPC_CODE"
    "$UPC_CODE0"
    "0$UPC_CODE0"
)

echo "Looking up UPC: $UPC_CODE (trying ${#UPC_FORMATS[@]} formats...)"
echo "================================"

# Function to query UPC ItemDB API
query_upc() {
    local upc="$1"
    curl -s "https://api.upcitemdb.com/prod/trial/lookup?upc=$upc" 2>/dev/null
}

# Try each UPC format
PRODUCT_FOUND=false
for format in "${UPC_FORMATS[@]}"; do
    RESPONSE=$(query_upc "$format")
    
    if [ -n "$RESPONSE" ]; then
        PRODUCT_COUNT=$(echo "$RESPONSE" | grep -o '"total":[0-9]*' | grep -o '[0-9]*')
        
        if [ "$PRODUCT_COUNT" != "0" ] && [ -n "$PRODUCT_COUNT" ]; then
            PRODUCT_FOUND=true
            break
        fi
    fi
done

if [ "$PRODUCT_FOUND" = false ]; then
    echo "❌ No product found for UPC: $UPC_CODE (tried all formats)"
    echo ""
    echo "🔍 Suggested alternatives:"
    echo "  - Use crawl4ai: node scripts/crawl4ai.mjs search \"UPC $UPC_CODE nutrition\""
    echo "  - Manual entry: $0 $UPC_CODE <calories> <protein> <carbs> <fat> <fiber> <confidence>"
    exit 0
fi

# Extract product info
PRODUCT_NAME=$(echo "$RESPONSE" | grep -o '"title":"[^"]*"' | head -1 | cut -d'"' -f4)
BRAND=$(echo "$RESPONSE" | grep -o '"brand":"[^"]*"' | head -1 | cut -d'"' -f4)
CATEGORY=$(echo "$RESPONSE" | grep -o '"category":"[^"]*"' | head -1 | cut -d'"' -f4)
IMAGE_URL=$(echo "$RESPONSE" | grep -o '"images":\["[^"]*"' | head -1 | grep -o 'https://[^"]*')

# Normalize product name for logging
NORM_NAME=$(echo "$PRODUCT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | sed 's/  */ /g' | sed 's/^ //;s/ $//')

if [ -z "$NORM_NAME" ]; then
    NORM_NAME="product UPC $UPC_CODE"
fi

echo "✅ Product Found!"
echo ""
echo "Product: $PRODUCT_NAME"
[ -n "$BRAND" ] && echo "Brand: $BRAND"
[ -n "$CATEGORY" ] && echo "Category: $CATEGORY"
[ -n "$IMAGE_URL" ] && echo "Image: $IMAGE_URL"
echo ""

# If nutritional data provided, log to calorie tracker
if [ -n "$CALORIES" ] && [ -n "$PROTEIN" ] && [ -n "$CARBS" ] && [ -n "$FAT" ]; then
    echo "📊 Logging to calorie tracker..."
    echo ""
    
    # Default confidence if not provided
    if [ -z "$CONFIDENCE" ]; then
        CONFIDENCE="0.85"
    fi
    
    # Log the meal
    LOG_OUTPUT=$(bash /home/node/.openclaw/workspace/scripts/calorie-log.sh "$NORM_NAME" "$CALORIES" "$PROTEIN" "$CARBS" "$FAT" "$FIBER" "$CONFIDENCE" 2>&1)
    
    echo "$LOG_OUTPUT"
    echo ""
    echo "✅ Logged with UPC: $UPC_CODE"
else
    echo "💡 Tip: Add nutritional data to auto-log:"
    echo "  $0 $UPC_CODE <calories> <protein> <carbs> <fat> <fiber> <confidence>"
    echo "  Example: $0 $UPC_CODE 320 4 48 14 0 0.80"
fi
