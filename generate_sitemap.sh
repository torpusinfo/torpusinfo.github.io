#!/bin/sh

DOMAIN="https://torpus.info"
OUTPUT="sitemap.xml"

echo '<?xml version="1.0" encoding="UTF-8"?>' > $OUTPUT
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> $OUTPUT

# find all *.htm and *.html except ignored ones
find . \
  -type f \( -name "*.htm" -o -name "*.html" \) \
  ! -name "404.htm" \
  ! -name "403.htm" \
  | while read -r file; do

    # strip leading "./"
    urlpath=$(echo "$file" | sed 's|^\./||')

    echo "  <url><loc>$DOMAIN/$urlpath</loc></url>" >> $OUTPUT
done

echo '</urlset>' >> $OUTPUT
echo "Generated $OUTPUT"
