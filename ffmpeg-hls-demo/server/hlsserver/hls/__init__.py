import asyncio
from contextlib import AsyncExitStack
import shutil
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory
from typing import Any, Dict, Mapping
from aiohttp import web
from hlsserver.domain import PersistedRadio
from hlsserver.hls.exceptions import ProcessLimitError

__all__ = ["on_startup", "on_cleanup", "start", "stop"]

_TASKS: Dict[str, asyncio.Task] = {}

async def on_startup(state: Mapping[str, Any]):
    state["assets"] = TemporaryDirectory(suffix="-hlsserv")
    state.router.add_static("/hls", state["assets"].name, show_index=True, follow_symlinks=True)

async def on_cleanup(state: Mapping[str, Any]):
    await asyncio.gather(*[task for task in _TASKS.values() if task.cancel()])
    if "assets" in state:
        state["assets"].cleanup()
        del state["assets"]

async def _stream(radio: PersistedRadio, workspace: Path, ffmpeg: Path, filename="stream.m3u8"):
    async with AsyncExitStack() as S:
        workspace.mkdir(exist_ok=True)
        S.callback(shutil.rmtree, workspace, ignore_errors=True)
        process = await asyncio.create_subprocess_exec(
            str(ffmpeg),
            "-i", radio.radio.url,
            "-f", "hls",
            "-hls_audio_peaks", "true",
            "-hls_flags", "delete_segments",
            "-acodec", "libmp3lame",
            "-q:a", "0",
            "-vn",
            str(workspace / filename),
            stdin=subprocess.DEVNULL, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL
        )
        S.push_async_callback(process.wait)
        S.callback(process.terminate)
        await process.wait()

async def start(radio: PersistedRadio, *, assets: TemporaryDirectory, ffmpeg: Path, **kwargs):
    if radio.key in _TASKS:
        return
    if len(_TASKS) >= 2:
        raise ProcessLimitError()
    _TASKS[radio.key] = asyncio.create_task(_stream(radio, Path(assets.name) / radio.key, ffmpeg))
    _TASKS[radio.key].add_done_callback(lambda *args: _TASKS.__delitem__(radio.key))

async def stop(radio: PersistedRadio, **kwargs):
    try:
        task = _TASKS[radio.key]
    except KeyError:
        return
    task.cancel()
    await task