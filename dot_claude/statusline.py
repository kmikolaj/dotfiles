#!/usr/bin/env python3
import json
import sys
import math
from datetime import datetime, timezone

def format_time_remaining(resets_at_epoch):
    """Given a Unix epoch timestamp, return a human-readable 'Xh Ym' or 'Ym' string
    for the time remaining until that moment. Returns None if the time is in the past
    or the value is missing."""
    if resets_at_epoch is None:
        return None
    now = datetime.now(timezone.utc).timestamp()
    secs_remaining = resets_at_epoch - now
    if secs_remaining <= 0:
        return None
    total_minutes = math.ceil(secs_remaining / 60)
    hours = total_minutes // 60
    minutes = total_minutes % 60
    if hours > 0:
        return f"{hours}h {minutes:02d}m"
    return f"{minutes}m"

def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    parts = []

    # Model name
    model_name = (data.get("model") or {}).get("display_name") or ""
    if model_name:
        parts.append(model_name)

    # Context window usage
    ctx = data.get("context_window") or {}
    used_pct = ctx.get("used_percentage")
    remaining_pct = ctx.get("remaining_percentage")
    if used_pct is not None and remaining_pct is not None:
        parts.append(f"ctx: {used_pct:.0f}% used ({remaining_pct:.0f}% left)")

    # Raw token counts from the last API call
    current = ctx.get("current_usage") or {}
    in_tok = current.get("input_tokens")
    out_tok = current.get("output_tokens")
    if in_tok is not None and out_tok is not None:
        parts.append(f"in:{in_tok} out:{out_tok}")

    # Rate limit reset times
    rate_limits = data.get("rate_limits") or {}
    rate_parts = []

    five_hour = rate_limits.get("five_hour") or {}
    if five_hour:
        five_used = five_hour.get("used_percentage")
        five_resets = five_hour.get("resets_at")
        time_str = format_time_remaining(five_resets)
        if five_used is not None:
            entry = f"5h: {five_used:.0f}% used"
            if time_str:
                entry += f" (reset {time_str})"
            rate_parts.append(entry)

    seven_day = rate_limits.get("seven_day") or {}
    if seven_day:
        seven_used = seven_day.get("used_percentage")
        seven_resets = seven_day.get("resets_at")
        time_str = format_time_remaining(seven_resets)
        if seven_used is not None:
            entry = f"7d: {seven_used:.0f}% used"
            if time_str:
                entry += f" (reset {time_str})"
            rate_parts.append(entry)

    if rate_parts:
        parts.append(" | ".join(rate_parts))

    print(" | ".join(parts))

if __name__ == "__main__":
    main()
