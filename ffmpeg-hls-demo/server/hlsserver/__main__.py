from inspect import isawaitable
from pathlib import Path
from typing import Optional
from aiohttp import web
from aiohttp.signals import Signal
from aiohttp.web_exceptions import HTTPBadRequest, HTTPInsufficientStorage
from aiohttp.web_middlewares import middleware, normalize_path_middleware
import fastjsonschema
from hlsserver import hls, logic
from hlsserver.domain import Radio
from hlsserver.hls.exceptions import ProcessLimitError
from argparse import ArgumentParser

@middleware
async def schema_validation_middleware(request: web.Request, handler):
    """Catches JsonSchemaValueException and re-raises as HTTPBadRequest."""
    try:
        return await handler(request)
    except fastjsonschema.JsonSchemaValueException as e:
        raise HTTPBadRequest(reason=e.message)

def install(module, *, into: web.Application, under: Optional[str] = None):
    """Installs a module into the application and connects any defined signals."""
    for attr in dir(module):
        fn = getattr(module, attr)
        if attr.startswith("on_") and callable(fn):
            try:
                signal = getattr(into, attr)
            except AttributeError:
                pass
            else:
                if isinstance(signal, Signal):
                    signal.append(fn)
                    if under is not None:
                        into[under] = module

def radio(routes: web.RouteTableDef, *, prefix: str = ""):
    @routes.post(prefix)
    async def post(request: web.Request):
        listener = request.app["listener"]
        try:
            data = listener.add(Radio.create(await request.json()), **request.app)
            return web.json_response((await data) if isawaitable(data) else data)
        except ProcessLimitError:
            raise HTTPInsufficientStorage(reason="Too many concurrent streams")

    @routes.get(prefix)
    async def index(request: web.Request):
        listener = request.app["listener"]
        data = listener.index(**request.app)
        return web.json_response((await data) if isawaitable(data) else data)

    @routes.get(prefix + "/{key}")
    async def select(request: web.Request):
        listener = request.app["listener"]
        key = request.match_info["key"]
        data = listener.select(key, **request.app)
        return web.json_response((await data) if isawaitable(data) else data)

    @routes.delete(prefix + "/{key}")
    async def delete(request: web.Request):
        listener = request.app["listener"]
        key = request.match_info["key"]
        data = listener.delete(key, **request.app)
        return web.json_response((await data) if isawaitable(data) else data)

    return routes

def main(application: web.Application, **kwargs):
    parser = ArgumentParser(description="HLS Provider")
    parser.add_argument("--assets", type=Path, required=True, help="Asset path")
    parser.add_argument("--host", default="127.0.0.1", help="Host address")
    parser.add_argument("--ffmpeg", type=Path, required=True, help="FFMPEG binary")
    args = parser.parse_args()

    application["ffmpeg"] = args.ffmpeg

    install(logic, into=application, under="listener")
    install(hls, into=application, under="hls")

    application.add_routes(radio(web.RouteTableDef(), prefix="/radio"))
    application.router.add_get("/", lambda req: web.FileResponse(args.assets / "index.html"))
    application.router.add_static("/static", args.assets)
    web.run_app(application, host=args.host)

if __name__ == "__main__":
    main(web.Application(middlewares=[normalize_path_middleware(append_slash=False, remove_slash=True), schema_validation_middleware]))