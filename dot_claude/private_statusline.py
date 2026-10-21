#!/usr/bin/env python3
import json
import sys
import math
from datetime import datetime, timezone

def format_time_remaining(resets_at_epoch):
    """Given a Unix epoch timestamp, return a human-readable 'Xd Yh', 'Xh Ym' or 'Ym' string
    for the time remaining until that moment. Returns None if the time is in the past
    or the value is missing."""
    if resets_at_epoch is None:
        return None
    now = datetime.now(timezone.utc).timestamp()
    secs_remaining = resets_at_epoch - now
    if secs_remaining <= 0:
        return None
    return format_duration(math.ceil(secs_remaining / 60))

def format_duration(total_minutes):
    """Format a number of minutes as 'Xd Yh', 'Xh Ym' or 'Ym'."""
    days = total_minutes // (24 * 60)
    hours = (total_minutes // 60) % 24
    minutes = total_minutes % 60
    if days > 0:
        return f"{days}d {hours}h"
    if hours > 0:
        return f"{hours}h {minutes:02d}m"
    return f"{minutes}m"

def color_pct(pct):
    """Format a percentage, colored yellow at >= 75% and red at >= 90%."""
    text = f"{pct:.0f}%"
    if pct >= 90:
        return f"\033[31m{text}\033[0m"
    if pct >= 75:
        return f"\033[33m{text}\033[0m"
    return text

EFFORT_LEVELS = {"low": "1", "medium": "2", "high": "3", "xhigh": "4", "max": "5"}

def format_tokens(n):
    """Format a token count compactly, e.g. 85000 -> '85k', 1000000 -> '1M'."""
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}".rstrip("0").rstrip(".") + "M"
    if n >= 1000:
        return f"{n / 1000:.0f}k"
    return str(n)

def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    parts = []

    # Model name
    model_name = (data.get("model") or {}).get("display_name") or ""
    effort = (data.get("effort") or {}).get("level")
    effort = EFFORT_LEVELS.get(effort, effort)
    if model_name and effort:
        parts.append(f"{model_name} ({effort})")
    elif model_name:
        parts.append(model_name)

    # Context window usage
    ctx = data.get("context_window") or {}
    used_pct = ctx.get("used_percentage")
    if used_pct is not None:
        entry = f"ctx: {color_pct(used_pct)}"
        total_in = ctx.get("total_input_tokens")
        ctx_size = ctx.get("context_window_size")
        if total_in is not None and ctx_size:
            entry += f" {format_tokens(total_in)}/{format_tokens(ctx_size)}"
        parts.append(entry)

    # Session duration
    duration_ms = (data.get("cost") or {}).get("total_duration_ms")
    if duration_ms is not None:
        parts.append(f"up: {format_duration(int(duration_ms // 60000))}")

    # Prompt cache: time until it goes cold
    cache = data.get("prompt_cache")
    if cache:
        time_str = format_time_remaining(cache.get("expires_at")) if cache.get("warm") else None
        parts.append(f"cache: {time_str or 'cold'}")

    # Rate limit reset times
    rate_limits = data.get("rate_limits") or {}
    rate_parts = []

    five_hour = rate_limits.get("five_hour") or {}
    if five_hour:
        five_used = five_hour.get("used_percentage")
        five_resets = five_hour.get("resets_at")
        time_str = format_time_remaining(five_resets)
        if five_used is not None:
            entry = f"5h: {color_pct(five_used)}"
            if time_str:
                entry += f" (reset {time_str})"
            rate_parts.append(entry)

    seven_day = rate_limits.get("seven_day") or {}
    if seven_day:
        seven_used = seven_day.get("used_percentage")
        seven_resets = seven_day.get("resets_at")
        time_str = format_time_remaining(seven_resets)
        if seven_used is not None:
            entry = f"7d: {color_pct(seven_used)}"
            if time_str:
                entry += f" (reset {time_str})"
            rate_parts.append(entry)

    if rate_parts:
        parts.append(" | ".join(rate_parts))

    print(" | ".join(parts))

if __name__ == "__main__":
    main()
