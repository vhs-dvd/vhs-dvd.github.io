# vhs-dvd.org.ua — інструкція з оновлення сайту

Сайт складається зі статичних HTML-сторінок + одного файлу даних `config.json`.
Усі ціни, телефони, графік, адреса та посилання на соцмережі беруться з `config.json`
і підтягуються на будь-яку сторінку автоматично (скрипт `includes/site.js`).

---

## Що редагувати

### Ціни → `config.json` → розділ `"pricing"`

```json
"pricing": [
  { "format": "VHS, VHS-C",  "price": "240", "unit": "/год", "tag": "Топ" },
  { "format": "MiniDisc (MD)", "price": "400", "unit": "/год", "tag": "" }
]
```

- `price` — число-рядок, `unit` — «/год» або «/кадр», `tag` — «Топ»/«Студійний» або порожньо
- Порядок рядків у таблиці = порядок у цьому масиві
- Ціна з'явиться у таблицях на **всіх сторінках** одразу після заливки файлу

### Телефони → розділ `"phones"`

```json
"phones": [
  { "number": "(093) 936-25-77", "tel": "+380939362577" }
]
```

- `number` — як показувати на кнопках, `tel` — куди дзвонити (без дужок і пробілів, з +38)
- Оновлюються: кнопки на головній і сторінці цін, блок «Контакти», футер

### Telegram → розділ `"telegram"`

- `url` + `label` — кнопка «Telegram чат» (вгорі та в контактах)
- `channelUrl` + `channelLabel` — «Telegram канал» у футері

### Графік, адреса → розділи `"schedule"` і `"address"`

- `weekdays` / `weekends` — рядки графіка
- `full` — повна адреса (контакти, сторінка цін), `short` — біля карти

### Соцмережі → розділ `"social"`

Посилання на YouTube / Facebook / Instagram — застосовуються до всіх іконок на сайті.

### Тексти й дизайн → HTML-файли

Тексти сторінок і SEO-описи (title, description) правляться прямо у `.html`.
Ціни в мета-тегах **немає** — описи не потребують правок при зміні цін.

---

## Що заливати на хостинг (FTP / панель)

| Що змінили | Що заливати |
|---|---|
| Ціни | **тільки `config.json`** |
| Телефони, Telegram, графік, адреса, соцмережі | **тільки `config.json`** |
| Текст або дизайн якоїсь сторінки | цей `.html` файл |
| Шапка / підвал / спільні стилі / скрипт | `includes/header.html`, `includes/footer.html`, `includes/site.css`, `includes/site.js` |
| Зображення | файл у `images/` |

Структура папки для хостингу:

```
config.json
index.html
ocyfrovka-*.html  (сторінки типів касет)
ocyfrovka-video-kyiv.html
skanuvannia-foto-ta-slaidiv.html
otsyfrovka-video-kyiv/index.html
includes/   (header.html, footer.html, site.css, site.js)
images/
favicon.ico, favicon-*.png, apple-touch-icon.png, android-chrome-*.png
site.webmanifest, robots.txt, sitemap.xml
```

> `.ps1` файли (serve.ps1) — лише для локального перегляду, на хостинг заливати не потрібно.

---

## Локальний перегляд

Відкривати `index.html` подвійним кліком **не можна** — браузер блокує `fetch` до
`config.json` (режим `file://`). Запустіть міні-сервер:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File serve.ps1
```

Сайт буде на `http://127.0.0.1:8765/index.html`. Зупинити — закрити вікно PowerShell
або `Stop-Process -Name powershell` у моніторі задач.

---

## Після публікації (щоб Google швидше побачив зміни)

1. [Google Search Console](https://search.google.com/search-console) → перевірка URL → «Запросити індексацію»
2. Соцмережі й месенджери кешують прев'ю: Telegram — через @WebpageBot, Facebook — [Sharing Debugger](https://developers.facebook.com/tools/debug/)

---

## Часті питання

**Змінив config.json, а на сайті старі дані.** → Оновіть сторінку з очищенням кешу
(Ctrl+F5). Хостинг не кешує config.json, але браузер може.

**Сайт «розібрався» — без стилів і без телефонів.** → Сторінку відкрито як файл
(`file://`). Запустіть `serve.ps1` (розділ «Локальний перегляд»).

**Помилка в консолі «Помилка завантаження config.json».** → Синтаксична помилка в
JSON: перевірте лапки, коми (перед `}` або `]` кома не потрібна). Сайт при цьому
показує старі статичні дані, не «падає».
