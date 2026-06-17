import argparse
import asyncio
import os
import re
import sys
import time
from pathlib import Path


PIPELINE_PATTERNS = [
    re.compile(r"PipelineCompleteness\s*[:=]\s*(?P<percent>\d+(?:\.\d+)?)\s*%", re.I),
    re.compile(r"Pipeline\s+Completeness\s*[:=]\s*(?P<percent>\d+(?:\.\d+)?)\s*%", re.I),
    re.compile(r"PipelineCompleteness\s*[:=]\s*(?P<percent>\d+(?:\.\d+)?)", re.I),
]

TEXT = {
    "en": {
        "start_reader": "Starting embedded iPhone log reader...",
        "connecting": "Connecting to iPhone over Apple Mobile Device Service...",
        "missing_reader": "Missing embedded iPhone log reader: {error}",
        "connected": "Connected. Waiting for Spotlight indexing logs...",
        "progress": "iOS indexing progress: {percent:g}%",
        "saw_no_percent": (
            "Saw an indexing log line, but it did not contain a percentage. "
            "Run again with --raw to inspect it."
        ),
        "duration_ended": "Watch duration ended.",
        "still_connected": "Still connected. Waiting for matching indexing logs...",
        "connect_timeout": "Could not connect to the iPhone within {seconds} seconds.",
        "checklist": (
            "Checklist: connect by USB, unlock the iPhone, tap Trust This Computer, "
            "then open Settings on the iPhone."
        ),
        "stopped": "Stopped.",
        "read_error": "Could not read iPhone logs: {message}",
        "latest": "Latest iOS indexing progress seen: {percent:g}%",
        "indexing_no_percent": (
            "Indexing-related logs appeared, but no percentage was found. "
            "Run again with --raw and compare the message text."
        ),
        "no_seen": "No indexing progress log was seen.",
        "no_seen_checklist": (
            "Checklist: keep the iPhone unlocked, trust this Windows PC, open Settings on the iPhone, "
            "leave it plugged in, and try a longer --duration value."
        ),
    },
    "zh": {
        "start_reader": "正在启动内置 iPhone 日志读取程序...",
        "connecting": "正在通过 Apple Mobile Device Service 连接 iPhone...",
        "missing_reader": "缺少内置 iPhone 日志读取组件：{error}",
        "connected": "已连接。正在等待 Spotlight 索引日志...",
        "progress": "iOS 索引进度：{percent:g}%",
        "saw_no_percent": "读到了索引相关日志，但没有找到百分比。如需排查，可用 --raw 查看原始内容。",
        "duration_ended": "监听时间已结束。",
        "still_connected": "仍然保持连接。正在等待匹配的索引日志...",
        "connect_timeout": "在 {seconds} 秒内没有连接到 iPhone。",
        "checklist": "请检查：用 USB 连接 iPhone，解锁，点“信任此电脑”，然后在 iPhone 上打开“设置”。",
        "stopped": "已停止。",
        "read_error": "无法读取 iPhone 日志：{message}",
        "latest": "最新 iOS 索引进度：{percent:g}%",
        "indexing_no_percent": "出现了索引相关日志，但没有找到百分比。如需排查，可用 --raw 对照原始内容。",
        "no_seen": "没有看到索引进度日志。",
        "no_seen_checklist": "请保持 iPhone 解锁，信任这台 Windows 电脑，在 iPhone 上打开“设置”，保持连接，然后可以尝试延长 --duration。",
    },
}


def tr(language: str, key: str, **kwargs) -> str:
    value = TEXT.get(language, TEXT["en"]).get(key, TEXT["en"][key])
    return value.format(**kwargs)


def timed(language: str, key: str, **kwargs) -> str:
    return f"[{time.strftime('%H:%M:%S')}] {tr(language, key, **kwargs)}"


def pipeline_percent(text: str) -> float | None:
    for pattern in PIPELINE_PATTERNS:
        match = pattern.search(text)
        if match:
            return float(match.group("percent"))
    return None


def is_interesting(text: str) -> bool:
    lower = text.lower()
    if "pipelinecompleteness" in lower:
        return True
    if "spotlight indexing progress" in lower:
        return True
    return "spotlight" in lower and "indexing" in lower and "progress" in lower


def handle_line(text: str, *, raw: bool, language: str) -> float | None:
    if not is_interesting(text):
        return None

    percent = pipeline_percent(text)
    if raw:
        print(text, flush=True)

    if percent is not None:
        print(timed(language, "progress", percent=percent), flush=True)
    elif not raw:
        print(timed(language, "saw_no_percent"), flush=True)

    return percent


def render_entry(entry) -> str:
    parts = []
    timestamp = getattr(entry, "timestamp", None)
    if timestamp is not None:
        parts.append(str(timestamp))

    filename = getattr(entry, "filename", "") or ""
    image_name = getattr(entry, "image_name", "") or ""
    pid = getattr(entry, "pid", "")
    level = getattr(getattr(entry, "level", None), "name", "")
    message = getattr(entry, "message", "") or ""

    if filename:
        parts.append(Path(filename).name)
    elif image_name:
        parts.append(Path(image_name).name)

    if pid != "":
        parts.append(f"[{pid}]")
    if level:
        parts.append(f"<{level}>:")
    if message:
        parts.append(message)

    label = getattr(entry, "label", None)
    if label is not None:
        subsystem = getattr(label, "subsystem", "") or ""
        category = getattr(label, "category", "") or ""
        if subsystem or category:
            parts.append(f"[{subsystem}][{category}]")

    return " ".join(str(part) for part in parts if str(part))


async def watch_device(args) -> int:
    print(tr(args.language, "start_reader"), flush=True)
    print(tr(args.language, "connecting"), flush=True)

    try:
        from pymobiledevice3.lockdown import create_using_usbmux
        from pymobiledevice3.services.os_trace import OS_TRACE_RELAY_STREAM_FLAGS_DEFAULT, OsTraceService
    except Exception as exc:
        print(tr(args.language, "missing_reader", error=exc), file=sys.stderr)
        return 20

    last_percent = None
    interesting_count = 0
    deadline = None if args.duration <= 0 else time.monotonic() + args.duration

    if args.udid:
        os.environ["PYMOBILEDEVICE3_UDID"] = args.udid

    try:
        lockdown_client = await asyncio.wait_for(
            create_using_usbmux(serial=args.udid),
            timeout=args.connect_timeout,
        )
        async with lockdown_client as lockdown:
            print(tr(args.language, "connected"), flush=True)
            stream = OsTraceService(lockdown=lockdown).syslog(
                pid=-1,
                stream_flags=OS_TRACE_RELAY_STREAM_FLAGS_DEFAULT,
            )
            iterator = stream.__aiter__()
            last_heartbeat = time.monotonic()

            try:
                while True:
                    now = time.monotonic()
                    if deadline is not None and now >= deadline:
                        print(tr(args.language, "duration_ended"), flush=True)
                        break

                    try:
                        entry = await asyncio.wait_for(iterator.__anext__(), timeout=5)
                    except asyncio.TimeoutError:
                        if time.monotonic() - last_heartbeat >= 10:
                            print(tr(args.language, "still_connected"), flush=True)
                            last_heartbeat = time.monotonic()
                        continue
                    except StopAsyncIteration:
                        break

                    line = render_entry(entry)
                    percent = handle_line(line, raw=args.raw, language=args.language)
                    if is_interesting(line):
                        interesting_count += 1
                    if percent is not None:
                        last_percent = percent

                    if deadline is not None and time.monotonic() >= deadline:
                        break
            finally:
                close = getattr(stream, "aclose", None)
                if close is not None:
                    try:
                        await close()
                    except Exception:
                        pass
                await asyncio.sleep(0.25)
    except asyncio.TimeoutError:
        print(
            tr(args.language, "connect_timeout", seconds=args.connect_timeout),
            file=sys.stderr,
            flush=True,
        )
        print(tr(args.language, "checklist"), file=sys.stderr, flush=True)
        return 2
    except KeyboardInterrupt:
        print(tr(args.language, "stopped"), flush=True)
    except Exception as exc:
        message = str(exc) or exc.__class__.__name__
        print(tr(args.language, "read_error", message=message), file=sys.stderr, flush=True)
        print(tr(args.language, "checklist"), file=sys.stderr, flush=True)
        return 2

    if last_percent is not None:
        print(tr(args.language, "latest", percent=last_percent), flush=True)
        return 0

    if interesting_count:
        print(tr(args.language, "indexing_no_percent"), flush=True)
        return 1

    print(tr(args.language, "no_seen"), flush=True)
    print(tr(args.language, "no_seen_checklist"), flush=True)
    return 3


def parse_input_file(args) -> int:
    last_percent = None
    interesting_count = 0
    with open(args.input, "r", encoding="utf-8", errors="replace") as handle:
        for line in handle:
            line = line.rstrip("\r\n")
            percent = handle_line(line, raw=args.raw, language=args.language)
            if is_interesting(line):
                interesting_count += 1
            if percent is not None:
                last_percent = percent

    if last_percent is not None:
        print(tr(args.language, "latest", percent=last_percent), flush=True)
        return 0
    if interesting_count:
        print(tr(args.language, "indexing_no_percent"), flush=True)
        return 1
    print(tr(args.language, "no_seen"), flush=True)
    return 3


def main() -> int:
    parser = argparse.ArgumentParser(description="Show iOS Spotlight indexing progress from Windows.")
    parser.add_argument("--duration", type=int, default=300, help="Seconds to watch. Use 0 to watch until Ctrl+C.")
    parser.add_argument("--connect-timeout", type=int, default=20, help="Seconds to wait for initial iPhone connection.")
    parser.add_argument("--udid", help="Target device UDID when multiple iPhones are connected.")
    parser.add_argument("--raw", action="store_true", help="Print raw matching log lines.")
    parser.add_argument("--input", help="Parse an existing log text file instead of connecting to a device.")
    parser.add_argument("--language", choices=("en", "zh"), default="en", help="UI language.")
    args = parser.parse_args()

    if args.input:
        return parse_input_file(args)

    if sys.platform == "win32":
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    try:
        result = loop.run_until_complete(watch_device(args))
        loop.run_until_complete(asyncio.sleep(0.5))
        return result
    finally:
        asyncio.set_event_loop(None)


if __name__ == "__main__":
    code = main()
    sys.stdout.flush()
    sys.stderr.flush()
    os._exit(code)
