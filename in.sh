#!/bin/sh

generate_blog() {
    echo "[*] Generating blog RSS feed"

    srcdir="."
    dstdir="$srcdir"
    blogdir="$srcdir/blogs"

    cat << EOF > "$dstdir/index.xml"
<feed xmlns="http://www.w3.org/2005/Atom">
	<title>Torpus' Blogs</title>
	<id>https://torpus.info/</id>
	<link rel="self" href="https://torpus.info/index.xml"></link>
	<author>
		<name>Torpus</name>
		<uri>https://torpus.info/</uri>
	</author>
EOF

    find "$blogdir" -name "*.htm" -type f | sort -r | while read filepath; do
        file="$(basename "$filepath")"

        [ "$file" = "index.htm" ] && continue

        title="$(grep -oP '(?<=<title>).*?(?=</title>)' "$filepath" | head -n 1)"
        timestamp="$(env TZ=UTC date -r "$filepath" '+%Y-%m-%dT%H:%M:%SZ')"
        summary="$title"

        header_image="$(sed -n '/<header>/,/<\/header>/p' "$filepath" | grep '<img' || true)"
        blog_content="$(sed -n '/<div class="blog-container">/,/<\/div>/p' "$filepath" | sed 's|^<div class="blog-container">||;s|</div>$||')"

        content="$header_image$blog_content"

        cat << EOF >> "$dstdir/index.xml"
<entry>
	<id>https://torpus.info/blogs/$file</id>
	<title>$title</title>
	<link rel="alternate" href="https://torpus.info/blogs/$file"/>
	<author>
		<name>Torpus</name>
	</author>
	<published>$timestamp</published>
	<rights>(CC-BY-SA)</rights>
	<summary type="text">$summary</summary>
	<content type="html">
		<![CDATA[$content]]>
	</content>
</entry>
EOF
    done

    echo "</feed>" >> "$dstdir/index.xml"

    echo "[*] RSS feed generated at $dstdir/index.xml"
}

generate_blog
