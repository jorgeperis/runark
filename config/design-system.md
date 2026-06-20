# Runark — Design System

> Guía viva del rebrand de **Arrow → Runark**. Define la dirección visual, los tokens y los
> patrones de componente. La landing (`app/views/pages/home.html.erb` +
> `app/assets/stylesheets/runark_landing.css`) es la primera implementación de referencia.
>
> **Estado:** v0.1 — landing. El resto de la app sigue con el tema antiguo (naranja/claro)
> hasta que se migre pantalla a pantalla siguiendo este documento.

## 1. Marca

- **Nombre:** Runark — de *run* + *ark* (arco / impulso hacia delante). Heredero de "Arrow":
  mantenemos la idea de avance/dirección, pero más nocturno y premium.
- **Personalidad:** preciso, deportivo, nocturno, para corredores que compiten. Menos "app
  amable", más "instrumento de rendimiento".
- **Voz:** directa, en segunda persona, orientada a datos. "Cada carrera. Cada récord.",
  no "¡Bienvenido a tu compañero de running!".
- **Wordmark:** `Runark` en Space Grotesk 700, tracking ligeramente cerrado (`-0.02em`),
  junto al ícono (arco/chevron ascendente en degradado rosa).

## 2. Dirección visual

**Neo-brutalismo: grafito + rosa + lima.** Siguiendo las tendencias 2026 ("tactile brutalism" /
anti-design), la landing es deliberadamente cruda y rompedora: tipografía descomunal en
mayúsculas, bordes gruesos de 2px, **sombras duras sin blur** (offset `7px 7px 0`), rejilla
expuesta (celdas con bordes visibles e índices `[01]`), monoespaciada para datos/etiquetas,
marquees en movimiento y bloques de color a sangre. Base grafito (no negro puro), rosa caliente
como color primario y lima flúor como secundario de alto voltaje. Nada de degradados naranjas
heredados, nada de esquinas blandas ni glows difusos.

Principios:
- **Bordes y sombras duras** antes que sombras suaves; contraste antes que sutileza.
- **La tipografía es la arquitectura**: titulares enormes, `line-height` < 1, tracking negativo.
- **Estructura expuesta**: rejillas con bordes visibles, índices, etiquetas mono tipo "//".
- **Disciplinado, no caótico**: brutalismo con rejilla clara y legible (evitar el anti-design
  que destroza la usabilidad — la app sigue siendo una herramienta de datos).
- El lima es alto voltaje: úsalo en bloques/estados puntuales, sin empapelar superficies.

## 3. Tokens

Se exponen como custom properties con prefijo `--rk-`. En la landing viven scopeados bajo
`.runark-landing`; cuando se migre la app pasarán a `:root`.

### Color — superficies (oscuro)

| Token                | Valor      | Uso                                    |
| -------------------- | ---------- | -------------------------------------- |
| `--rk-bg`            | `#18181C`  | Fondo base de página                   |
| `--rk-surface-1`     | `#202024`  | Paneles, secciones alternas            |
| `--rk-surface-2`     | `#27272C`  | Cards sobre panel                      |
| `--rk-surface-3`     | `#323238`  | Elevado / hover                        |
| `--rk-border`        | `#34343C`  | Bordes sutiles                         |
| `--rk-border-strong` | `#48484F`  | Bordes de énfasis / inputs             |

### Color — texto

| Token              | Valor     | Uso                          |
| ------------------ | --------- | ---------------------------- |
| `--rk-text`        | `#FAFAFA` | Texto principal              |
| `--rk-text-muted`  | `#A1A1AA` | Secundario / leads           |
| `--rk-text-faint`  | `#71717A` | Etiquetas, metadatos, footer |

### Color — marca (rosa)

| Token             | Valor     | Uso                               |
| ----------------- | --------- | --------------------------------- |
| `--rk-pink`       | `#F43F8E` | Acento primario (hot pink)        |
| `--rk-pink-bright`| `#F472B6` | Hover / luz                       |
| `--rk-pink-deep`  | `#DB2777` | Pressed / sombra de degradado     |
| `--rk-pink-soft`  | `rgba(244,63,142,.12)` | Fondos tenue, chips  |
| `--rk-gradient`   | `linear-gradient(135deg,#F43F8E 0%,#EC4899 55%,#FB7185 100%)` | CTAs, texto destacado, mark |
| `--rk-lime`       | `#D4FF3F` | Acento secundario (lima flúor): dots, badges de estado |
| `--rk-lime-soft`  | `rgba(212,255,63,.12)` | Halo/fondo tenue del lima         |

### Tipografía

- **Display:** `'Space Grotesk'` (titulares descomunales en MAYÚSCULAS, wordmark, números).
- **Mono:** `'Space Mono'` (etiquetas, datos, índices, botones, marquees). Es la voz "técnica".
- **Texto:** `'Plus Jakarta Sans'` (cuerpo / leads). Pesos 400–800.
- Titulares: `text-transform: uppercase`, `letter-spacing: -0.03em/-0.04em`, `line-height: 0.88–0.95`.
- Hero `clamp(3rem, 9.5vw, 8rem)`; secciones `clamp(2rem, 5vw, 3.5rem)`.
- Recursos brutalistas de tipo: `-webkit-text-stroke` (texto outline lima) y resaltado en
  bloque (`.rk-hl-pink`: fondo rosa + texto tinta, `box-decoration-break: clone`).

### Bordes · sombras · radios

- **Borde estándar:** `2px solid var(--rk-text)` (`--rk-line`). También variante rosa.
- **Sombra dura (sin blur):** `7px 7px 0 0 <color>` — tokens `--rk-shadow-pink/-lime/-ink`.
  Hover: crece a `10px 10px`; active: cae a `3px 3px` (efecto "press").
- **Radios:** 0 (esquinas vivas). El único redondeo permitido son dots de estado (`999px`).
- Fondo: rejilla de ingeniería sutil (`background-size: 48px`) para textura.

## 4. Componentes (landing)

- **`.rk-btn`** — borde 2px + sombra dura; variantes `--pink`, `--lime`, `--ink`, `--sm`.
  Hover desplaza `-3px,-3px`; active `2px,2px`. Botones en monoespaciada/mayúsculas.
- **`.rk-marquee`** — banda a sangre (rosa o lima) con texto mono en bucle; `--rev` invierte,
  hover pausa, respeta `prefers-reduced-motion`.
- **`.rk-eyebrow`** — etiqueta mono lima con prefijo `//` rosa.
- **`.rk-data-row` / `.rk-data-cell`** — rejilla de datos con bordes visibles e índices `[0n]`.
- **`.rk-card`** (features) — celdas en rejilla expuesta, índice `[0n]`, ícono en bloque
  rosa/lima con borde; hover cambia el fondo (sin sombras suaves).
- **`.rk-mockup`** — card cruda, borde 2px, sombra dura rosa, `rotate(-1.5deg)`.
- **`.rk-cta-panel`** — bloque rosa a sangre con sombra dura lima y titular gigante en tinta.
- Sin glows difusos, sin degradados, sin esquinas blandas.

## 5. Pendiente (siguientes pasos del rebrand)

1. Renombrar `Arrow → Runark` en layouts, `<title>`, mailer y `module Arrow`.
2. Sustituir el ícono naranja (`#FF6B35→#F7931E`) por el mark rosa en ambos layouts.
3. Migrar tokens `--rk-*` a `:root` y reescribir `base.css`/`button.css` sobre la paleta nueva.
4. Decidir modo claro/oscuro para las pantallas internas (la app hoy es clara).
