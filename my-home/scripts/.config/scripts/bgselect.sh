#!/usr/bin/env bash

WALL_DIR="$HOME/.config/wallpapers"
CACHE_DIR="$HOME/.cache/thumbnails/bgselector"
CACHE_INDEX="$CACHE_DIR/.index"
ONLY_WALLS=false
ONLY_COLORS=false

while [[ $# -gt 0 ]]; do
	case $1 in
		--only-walls)
			ONLY_WALLS=true
			shift
			;;
		--only-colors)
			ONLY_COLORS=true
			shift
			;;
		*)
			shift
			;;
	esac
done

mkdir -p "$CACHE_DIR"

current_index=$(mktemp)
find -L "$WALL_DIR" \( -type f -o -type l \) \( \
    -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o \
    -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' -o \
    -iname '*.tiff' -o -iname '*.avif' \
\) -printf '%p\n' > "$current_index"

if [ -f "$CACHE_INDEX" ]; then
    while read -r cached_path; do
        if [ ! -f "$cached_path" ]; then
            rel_path="${cached_path#$WALL_DIR/}"
            cache_name="${rel_path//\//_}"
            cache_name="${cache_name%.*}.jpg"
            rm -f "$CACHE_DIR/$cache_name"
        fi
    done < "$CACHE_INDEX"
fi

progress_file=$(mktemp)
touch "$progress_file"

max_jobs=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
job_count=0

to_generate=$(mktemp)
while read -r img; do
    rel_path="${img#$WALL_DIR/}"
    cache_name="${rel_path//\//_}"
    cache_name="${rel_path%.*}.jpg"
	cache_name="${cache_name//\//_}"
    cache_file="$CACHE_DIR/$cache_name"
    
    [ -f "$cache_file" ] || echo "$img" >> "$to_generate"
done < "$current_index"

generate_thumbnail() {
    local img="$1"
    local cache_dir="$2"
    local wall_dir="$3"
    local progress="$4"
    
    local rel_path="${img#$wall_dir/}"
    local cache_name="${rel_path//\//_}"
    cache_name="${cache_name%.*}.jpg"
    local cache_file="$cache_dir/$cache_name"
    
    local frame=""
    [[ "${img,,}" =~ \.gif$ ]] && frame="[0]"

	magick -regard-warnings "${img}${frame}" \
        -colorspace sRGB \
        -filter Triangle \
        -thumbnail 330x540^ \
        -gravity center -extent 330x540 \
        -background "#111111" -flatten \
        -strip -quality 80 +repage \
        "$cache_file" 2>/dev/null

    if [[ -s "$cache_file" ]]; then
        echo "1" >> "$progress"
    fi
}
export -f generate_thumbnail
if command -v xargs >/dev/null 2>&1 && [ -s "$to_generate" ]; then
    cat "$to_generate" | xargs -P "$max_jobs" -I {} bash -c \
        'generate_thumbnail "$1" "$2" "$3" "$4"' _ {} "$CACHE_DIR" "$WALL_DIR" "$progress_file"
elif [ -s "$to_generate" ]; then
    while read -r img; do
        generate_thumbnail "$img" "$CACHE_DIR" "$WALL_DIR" "$progress_file" &
        ((job_count++))
        if [ $((job_count % max_jobs)) -eq 0 ]; then
            wait -n 2>/dev/null || wait
        fi
    done < "$to_generate"
    wait
fi

rm -f "$to_generate"

total_generated=$(wc -l < "$progress_file" 2>/dev/null || echo 0)
[ $total_generated -gt 0 ] && echo "Generated $total_generated thumbnails" || echo "Cache up to date"
rm -f "$progress_file"

mv "$current_index" "$CACHE_INDEX"

rofi_input=$(mktemp)
while read -r img; do
    rel_path="${img#$WALL_DIR/}"
    cache_name="${rel_path//\//_}"
    cache_name="${cache_name%.*}.jpg"
    cache_file="$CACHE_DIR/$cache_name"
    
    [ -f "$cache_file" ] && printf '%s\000icon\037%s\n' "$rel_path" "$cache_file"
done < "$CACHE_INDEX" > "$rofi_input"

selected=$(rofi -dmenu -show-icons -config "$HOME/.config/rofi/bgselector/style.rasi" < "$rofi_input")
rm "$rofi_input"

if [ -n "$selected" ]; then
    selected_path="$WALL_DIR/$selected"
    if [ -f "$selected_path" ]; then
		if ! $ONLY_COLORS; then
			awww img "$selected_path" -t fade --transition-duration 2 --transition-fps 30 &
			sleep 0.5
		fi
		if ! $ONLY_WALLS; then
			"$HOME/.config/scripts/theme-sync.sh" --wall-path "$selected_path" &
		fi
        wait
    fi
fi
