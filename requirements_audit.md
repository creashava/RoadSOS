# RoadSOS — Requirements Audit Report

> **Audited:** 18 May 2026  
> **Scope:** [requirements.md](file:///c:/Users/HP/Desktop/code/Projects/roadsos/requirements.md) vs. actual codebase  
> **Verdict:** The project covers the core requirements well, with strong architectural choices. Several evaluation-criteria areas have room for improvement.

---

## 1. Requirement-by-Requirement Assessment

### 1.3.3 KEY ASPECTS FOR CODERS

| # | Requirement | Status | Rating | Evidence / Notes |
|---|------------|--------|--------|-----------------|
| 1 | **Nearest Police Stations** | ✅ Implemented | **8/10** | Overpass query `amenity=police` in [overpass.js](file:///c:/Users/HP/Desktop/code/Projects/roadsos/src/services/overpass.js#L11). Shown in Emergency page under `police` category. Also fetched from Supabase as a secondary source. Deduplication by proximity in place. |
| 2 | **Nearest Hospitals** | ✅ Implemented | **8/10** | `amenity=hospital` + `amenity=clinic` + `amenity=pharmacy` — three separate medical categories. Sorted by distance via Haversine. |
| 3 | **Ambulance Services** | ✅ Implemented | **7/10** | `emergency=ambulance_station` queried. However, ambulance **stations** are rare on OSM in many countries. The app compensates with the emergency number dial (country-specific ambulance number). Rating docked because coverage depends heavily on local OSM data quality. |
| 4 | **Towing Services** | ✅ Implemented | **8/10** | Three OSM tag variants queried: `amenity=towing`, `shop=towing`, `service:vehicle:towing=yes`. Good tag coverage. |
| 5 | **Nearest Puncture Shops** | ✅ Implemented | **7/10** | Queries `shop=tyres`, `craft=tyre`, `service:bicycle:repair=yes`. The bicycle-repair tag may return false positives (bike shops vs. tyre puncture for vehicles). Minor data quality concern. |
| 6 | **Showrooms** | ✅ Implemented | **7/10** | `shop=car` and `amenity=car_sales`. These are less commonly tagged on OSM globally, but the implementation is correct. |
| 7 | **Global applicability across countries** | ✅ Implemented | **8/10** | Uses OSM Overpass API (global coverage). Country detection via Nominatim reverse geocoding. Emergency numbers for **14 countries** + DEFAULT fallback (`112`). Works anywhere with OSM data. |
| 8 | **Offline functionality** | ✅ Implemented | **8/10** | PWA with Service Worker (Workbox via `vite-plugin-pwa`). IndexedDB caching (Dexie) for services and location. OSM tile caching (CacheFirst, 30-day expiry, 500 tiles). First Aid guides are fully offline (bundled JSON). Offline banner shown to user. |
| 9 | **Low-network robustness** | ✅ Implemented | **7/10** | `Promise.allSettled` used for Overpass + Supabase calls (graceful partial failure). Cache-first strategy with 10-min TTL. Falls back to cached data when offline. However, there's no request retry/backoff logic or queue for failed incident reports when offline. |

---

### 1.3.4 EVALUATION CRITERIA

| # | Criterion | Status | Rating | Analysis |
|---|----------|--------|--------|----------|
| 1 | **Reliability and data accuracy** | ✅ Solid | **7.5/10** | Dual data sources (Overpass + Supabase PostGIS). Deduplication by proximity avoids duplicates. Haversine distance calculation is correct. Fresh GPS on every report submission. **Gap:** No data validation/confidence indicator for OSM entries (e.g. how recently the POI was updated). |
| 2 | **Number of contacts fetched** | ✅ Good | **7/10** | 13 service types queried across medical, emergency, and vehicle categories. 10km default radius. Supabase limits to 20 results per type. Overpass has no explicit limit — returns all within radius. **Gap:** Phone numbers depend on OSM `phone` / `contact:phone` tags, which are often missing. No supplementary data source for phone numbers. |
| 3 | **Offline functionality** | ✅ Strong | **8/10** | Full PWA (installable, standalone mode). IndexedDB for services + location. Service Worker caches all static assets + map tiles. First Aid is fully offline. **Gap:** Incident reports fail silently when offline — no offline queue + sync mechanism. |
| 4 | **Innovation & additional features** | ✅ Excellent | **9/10** | This is where the project shines. See "Innovation Inventory" below. |
| 5 | **Information integration across countries** | ✅ Good | **8/10** | 14 country-specific emergency number sets. Nominatim auto-detects country. OSM is global. **Gap:** Only 14 explicit countries — could be expanded to 50+ easily. No language localization beyond English. |

---

## 2. Innovation Inventory (Beyond Requirements)

These features go beyond the stated requirements and demonstrate strong product thinking:

| Feature | Implementation Quality | Impact |
|---------|----------------------|--------|
| **🚨 Crash Detection** (accelerometer-based) | **9/10** — Uses DeviceMotion API with threshold tuning (28 m/s² prod, 8 dev), iOS permission handling, probe for blocked sensors, 10s countdown with cancel, auto-WhatsApp + auto-incident-report on expiry. Very well engineered. | 🔴 **Critical differentiator** |
| **📋 Emergency Profile (QR)** | **8/10** — Blood group, allergies, medical conditions, emergency contact. Generates QR code, supports scanning via camera or image upload. Persisted in Supabase with UUID. Viewable at `/card/:uuid`. | 🟡 High — life-saving during golden hour |
| **🗺️ Live Incident Map** | **8/10** — Real-time Supabase subscriptions (INSERT/UPDATE). Severity badges, photo attachments, landmark info. Leaflet map with incident pins. | 🟡 High — community-powered situational awareness |
| **📸 Incident Reporting** | **8/10** — Camera capture + gallery upload, severity scale, victim count, landmark, GPS banner, fresh GPS on submit. Posts to Supabase. | 🟡 High |
| **🩺 First Aid Guides** | **8/10** — 8 comprehensive guides (bleeding, CPR, fractures, spinal, head, shock, burns, impaled). Step-by-step with warnings. YouTube video embeds. Call Ambulance + SMS buttons. Fully offline. | 🟢 Medium-High |
| **📤 Location Sharing** | **7/10** — WhatsApp, SMS, clipboard copy. Pre-filled emergency messages. | 🟢 Medium |
| **🏥 Triage Flow** | **7/10** — Victim vs. Bystander paths with different service priority ordering. | 🟢 Medium |
| **📍 QuickBall FAB** | **7/10** — Floating action button for quick access. | 🟢 Medium |
| **🎨 MD3 Design System** | **8/10** — Consistent Material Design 3 language across pages. Dark theme. Ripple effects. | 🟢 Medium |

---

## 3. Gaps & Flags

### 🔴 Not Implemented / Missing

| Gap | Severity | Impact on Evaluation |
|-----|----------|---------------------|
| **No offline incident reporting queue** — reports fail silently when offline; no background sync | Medium | Hurts "Offline functionality" criterion |
| **No voice-activated SOS** — in a severe crash, the victim may not be able to tap the screen | Medium | Missed innovation opportunity |
| **No multi-language / i18n support** — English only despite "global applicability" claim | Medium | Hurts "Information integration across countries" |
| **Emergency number dataset is thin** — only 14 countries | Low-Medium | Could be expanded to 190+ with a simple JSON expansion |

### 🟡 Partially Implemented / Weak

| Area | Issue | Recommendation |
|------|-------|----------------|
| **Phone numbers for services** | Many OSM entries lack phone/contact tags. Users see services but can't call them. | Add a "Search Google for phone" fallback link, or integrate a secondary directory API. |
| **Crash detection false positives** | 28 m/s² threshold is reasonable but a single spike can trigger it. No time-window or multi-sample confirmation. | Require 2+ spikes within 500ms, or use a rolling average filter. |
| **Video embeds in First Aid** | YouTube iframes won't load offline — contradicts the "Available Offline" badge on the First Aid page. | Clearly indicate videos require internet, or bundle short clips as assets. |
| **Service Worker scope** | Only static assets + OSM tiles are cached. Overpass API responses are not runtime-cached by the SW. | Add Workbox runtime caching for the Overpass endpoint (StaleWhileRevalidate). |
| **`console.log` in production** | `overpass.js:80` logs the full Overpass response. Debug-only code should be behind `import.meta.env.DEV`. | Guard with `if (import.meta.env.DEV)`. |

---

## 4. Overall Scorecard

| Dimension | Score | Grade |
|-----------|-------|-------|
| Core Requirements Coverage | 8.0 / 10 | **A-** |
| Offline & Robustness | 7.5 / 10 | **B+** |
| Global Applicability | 7.5 / 10 | **B+** |
| Innovation & Extra Features | 9.0 / 10 | **A** |
| Code Quality & Architecture | 8.5 / 10 | **A** |
| Data Reliability | 7.0 / 10 | **B** |
| **Overall** | **7.9 / 10** | **B+** |

---

## 5. Suggested Extra Features (Prioritized)

### 🔴 Tier 1 — High Impact, Aligned with Requirements

| Feature | Description | Effort |
|---------|-------------|--------|
| **Offline Incident Queue** | Queue incident reports in IndexedDB when offline. Auto-sync via Background Sync API when connectivity returns. | Medium |
| **Expanded Emergency Numbers** | Expand `emergency-numbers.json` to 100+ countries using public datasets (e.g., Wikipedia's emergency number list). | Low |
| **SOS Shake Trigger** | Alternative activation — shake the phone vigorously to trigger SOS (in addition to crash detection and the button). | Low |
| **Nearest Service Phone Enrichment** | When OSM `phone` tag is missing, generate a Google Maps search link so the user can find the number. | Low |

### 🟡 Tier 2 — Differentiators for Evaluation

| Feature | Description | Effort |
|---------|-------------|--------|
| **Voice SOS** | Web Speech API — say "help" or "SOS" to trigger the emergency flow hands-free. | Medium |
| **Offline Map Pre-download** | Allow users to pre-cache map tiles for their area (e.g., 5km radius) before a trip. Show a "Download Map" button. | Medium |
| **Multi-language UI** | i18n with at least 5 languages (Hindi, Spanish, French, German, Arabic) using a simple JSON translation system. | Medium |
| **Real-time Ambulance ETA** | If ambulance services have open APIs in the region, show estimated arrival time. Fallback: show distance-based estimate. | High |
| **Emergency Dashboard Widget** | A single-screen "dashboard" showing: nearest hospital, nearest police, emergency number, and a one-tap call button. No navigation required. | Low |

### 🟢 Tier 3 — Nice-to-Have Polish

| Feature | Description | Effort |
|---------|-------------|--------|
| **Dark/Light Theme Toggle** | Currently dark only. Add a toggle for accessibility (some users may need high-contrast light mode). | Low |
| **Haptic Feedback** | Vibrate on SOS activation, crash detection countdown, and critical actions. | Low |
| **Service Ratings** | Let users rate services they contacted (was the hospital responsive?). Store in Supabase. | Medium |
| **Trip Mode** | "I'm driving" mode — heightened crash detection sensitivity, pre-caches services along the route. | High |
| **Insurance/Document Vault** | Store insurance policy, vehicle registration, and license photos for quick access during incidents. | Medium |

---

## 6. Quick Wins (< 1 hour each)

1. **Expand emergency numbers** to 50+ countries — just JSON editing
2. **Guard `console.log`** in `overpass.js` behind `import.meta.env.DEV`
3. **Add "Videos require internet" disclaimer** on First Aid guide page
4. **Add Google Maps search fallback** when service phone number is null
5. **Add haptic feedback** (`navigator.vibrate()`) on SOS button press and crash alert

---

> [!IMPORTANT]
> The project is well-built and exceeds the basic requirements significantly. The crash detection, QR emergency profile, and live incident map are genuine innovations. The main areas to strengthen before evaluation are **expanding the country coverage** (easy win), **adding offline report queuing** (medium effort, high impact), and **enriching phone number data** for discovered services.
