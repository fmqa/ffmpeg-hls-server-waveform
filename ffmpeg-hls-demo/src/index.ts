import Hls, { ErrorData, Events } from 'hls.js';
import { css } from 'lit';
import { html, LitElement } from 'lit-element/lit-element.js';
import { customElement, property, query, queryAsync } from 'lit/decorators.js';
import { Observable, Subject } from 'rxjs';
import { map, takeUntil } from 'rxjs/operators';

function roll<T>(limit: number) {
  return (obserable: Observable<T>): Observable<T[]> => {
    const buffer: T[] = [];
    return obserable.pipe(map(x => {
      if (buffer.length >= limit) {
        buffer.shift();
      }
      buffer.push(x);
      return buffer;
    }));
  }
}

@customElement("loudness-plot")
export class LoudnessPlotElement extends LitElement {
  static override readonly styles = css`canvas { width: inherit; height: inherit; }
  span { float: right; font-family: "Monospace"; font-size: 10px; white-space: pre; font-weight: bold; }
  .top { position: absolute; }
  .bottom { float: unset; }
  `;

  @query("canvas")
  protected _canvas!: HTMLCanvasElement;

  public readonly data$ = new Subject<number>();

  protected readonly _window$ = this.data$.pipe(roll(64));
  protected readonly _destroy$ = new Subject<boolean>();

  @property({type: Number})
  public width = 256;

  override connectedCallback() {
    this._window$.pipe(takeUntil(this._destroy$)).subscribe(w => {
      const context = this._canvas.getContext("2d");
      if (!context) {
        return;
      }
      const { width, height } = this._canvas;
      context.clearRect(0, 0, width, height);
      w.forEach((h, x) => {
        if (h <= -60) {
          context.fillStyle = "yellow";
        } else if (h <= -20) {
          context.fillStyle = "orange";
        } else {
          context.fillStyle = "red";
        }
        h = (Math.floor(h) + 96) / 96;
        h *= height;
        h = Math.floor(h);
        context.fillRect(4 * x, height - h, 2, h);
      });
    });
    super.connectedCallback();
  }

  override disconnectedCallback() {
    this._destroy$.next(true);
    this._destroy$.complete();
    this._destroy$.unsubscribe();
    super.disconnectedCallback();
  }

  override render() {
    return html`<canvas width=${this.width}></canvas><span class="top">-0  dBFS</span><span class="bottom">-96 dBFS</span>`;
  }
}

@customElement("hls-live-audio")
export class HLSLiveElement extends LitElement {
  static override readonly styles = css`:host { display: flex; flex-direction: column; }
  loudness-plot { align-self: center; margin: 8px; border: 1px solid; }`;

  protected readonly _hls = new Hls();

  @queryAsync("loudness-plot")
  protected _plot!: Promise<LoudnessPlotElement>;

  @queryAsync("audio")
  protected _audio!: Promise<HTMLAudioElement>;

  @property({type: String})
  public src = "";

  constructor() {
    super();
    Promise.all([this._plot, this._audio]).then(([plot, audio]) => this._hls.on(Hls.Events.FRAG_CHANGED, (event, data) => {
      if (audio.paused) {
        return;
      }
      const { tagList } = data.frag;
      const entry = tagList.find(([k, _]) => k === "EXT-X-LOUDNESS");
      if (!entry) {
        return;
      }
      const [/* key */, loudness] = entry;
      const match = loudness.match(/^UNIT=(\w+),SPP=(.*),PEAKS=(.*)$/);
      if (!match) {
        return;
      }
      const [/* groups */, /* unit */, spp, peaks] = match;
      const f = +spp;
      const points: number[] = JSON.parse(`[${peaks}]`);
      let index = 0;
      const func = () => {
        while (data.frag.start + f * index <= audio.currentTime) {
          plot.data$.next(points[index++])
        }
        if (index < points.length) {
          setTimeout(func, f * 500);
        }
      };
      func();
    }));
  }

  override willUpdate(changedProperties: Map<string | number | symbol, unknown>) {
    if (changedProperties.has("src")) {
      const onError = (a: Events, b: ErrorData) => {
        if (b.details === Hls.ErrorDetails.MANIFEST_LOAD_ERROR) {
          setTimeout(() => this._hls.loadSource(this.src), 1000)
        }
      };
      const onSuccess = (a: Events) => {
        this._hls.off(Hls.Events.MANIFEST_LOADED, onSuccess);
        this._hls.off(Hls.Events.ERROR, onError);
      } 
      this._hls.on(Hls.Events.ERROR, onError);
      this._hls.on(Hls.Events.MANIFEST_LOADED, onSuccess);
      this._hls.loadSource(this.src);
      this._audio.then(audio => this._hls.attachMedia(audio));
    }
    super.willUpdate(changedProperties);
  }

  override render() {
    return html`<loudness-plot></loudness-plot><audio controls></audio>`;
  }
}

@customElement("add-radio")
export class AddRadioElement extends LitElement {
  static override readonly styles = css`* { margin: 2px; }`;

  @query("input")
  protected _url!: HTMLInputElement;

  override render() {
    return html`<input type="url"></input><button @click="${this._play}">Play</button>`;
  }

  private _play(e: Event) {
    this.dispatchEvent(new CustomEvent("play", {bubbles: true, composed: true, detail: this._url.value}));
  }
}

@customElement("app-main")
export class AppMainElement extends LitElement {
  static override readonly styles = css`hls-live-audio { width: 512px; }`

  protected readonly _items: string[] = [];

  override render() {
    return html`${this._items.map(item => html`<hls-live-audio src="${item}"></hls-live-audio>`)}<add-radio @play="${this._play}"></add-radio>`;
  }

  private _play(e: CustomEvent) {
    fetch("/radio", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        name: e.detail,
        url: e.detail
      })
    })
    .then(response => response.json())
    .then(response => this._items.push(`/hls/${response.key}/stream.m3u8`) && this.requestUpdate());
  }
}