from base64 import urlsafe_b64decode
from dataclasses import asdict
import sqlite3
from typing import Any, Mapping
from hlsserver.domain import PersistedRadio, Radio

__all__ = ["on_startup", "on_cleanup", "add", "index", "select", "delete"]

async def on_startup(state: Mapping[str, Any]):
    state["db"] = sqlite3.connect(":memory:")
    state["db"].row_factory = sqlite3.Row
    state["db"].execute("CREATE TABLE radios(name text primary key, url text)")

async def on_cleanup(state: Mapping[str, Any]):
    if "db" in state:
        state["db"].close()
        del state["db"]

async def add(radio: Radio, *, db: sqlite3.Connection, hls, **kwargs):
    with db:
        db.execute("INSERT INTO radios VALUES(:name, :url) ON CONFLICT(name) DO UPDATE SET url=excluded.url", asdict(radio))
    item = PersistedRadio.create(radio)
    await hls.start(item, **kwargs)
    return asdict(item)

def index(*, db: sqlite3.Connection, **kwargs):
    with db:
        items = [asdict(PersistedRadio.create(Radio(**row))) for row in db.execute("SELECT * FROM radios")]
    return items

def select(key: str, *, db: sqlite3.Connection, **kwargs):
    key = key.encode("utf-8")
    key = urlsafe_b64decode(key)
    key = key.decode("utf-8")
    with db:
        cursor = db.execute("SELECT * FROM radios WHERE name = ?", [key])
        first = cursor.fetchone()
    first = PersistedRadio.create(Radio(**first))
    return asdict(first)

async def delete(key: str, *, db: sqlite3.Connection, hls, **kwargs):
    key = key.encode("utf-8")
    key = urlsafe_b64decode(key)
    key = key.decode("utf-8")
    with db:
        cursor = db.execute("SELECT * FROM radios WHERE name = ?", [key])
        first = cursor.fetchone()
    first = PersistedRadio.create(Radio(**first))
    await hls.stop(first, **kwargs)
    with db:
        cursor = db.execute("DELETE FROM radios WHERE name = ?", [key])
    return cursor.rowcount