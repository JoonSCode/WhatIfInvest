import fs from "node:fs/promises";
import path from "node:path";

export const dynamic = "force-dynamic";

type Manifest = {
  locales: Array<{
    identifier: string;
    scenes: Array<{
      slug: string;
      eyebrow: string;
      title: string;
      subtitle: string;
      chips: string[];
      palette: {
        background_top: string;
        background_bottom: string;
        accent: string;
        accent_soft: string;
        text_primary: string;
        text_secondary: string;
      };
    }>;
  }>;
};

type Slide = {
  id: string;
  eyebrow: string;
  title: string;
  body: string;
  chips: string[];
  accent: string;
  accentSoft: string;
  backgroundTop: string;
  backgroundBottom: string;
  textPrimary: string;
  textSecondary: string;
  screen: string;
};

const CANVAS_W = 1320;
const CANVAS_H = 2868;
const MOCKUP_W = 1022;
const MOCKUP_H = 2082;
const SCREEN_LEFT = (52 / MOCKUP_W) * 100;
const SCREEN_TOP = (46 / MOCKUP_H) * 100;
const SCREEN_WIDTH = (918 / MOCKUP_W) * 100;
const SCREEN_HEIGHT = (1990 / MOCKUP_H) * 100;
const SCREEN_RX = (126 / 918) * 100;
const SCREEN_RY = (126 / 1990) * 100;

function resolveLocale(input?: string | string[]) {
  const value = Array.isArray(input) ? input[0] : input;
  return value?.trim() || process.env.WHATIFINVEST_MARKETING_LOCALE || "en-US";
}

async function loadSlides(requestedLocale?: string | string[]): Promise<{ locale: string; slides: Slide[] }> {
  const locale = resolveLocale(requestedLocale);
  const manifestPath = path.resolve(process.cwd(), "../screenshots/scene_manifest.json");
  const manifest = JSON.parse(await fs.readFile(manifestPath, "utf8")) as Manifest;
  const localeEntry =
    manifest.locales.find((entry) => entry.identifier === locale) ??
    manifest.locales.find((entry) => entry.identifier.toLowerCase() === locale.toLowerCase()) ??
    manifest.locales[0];

  return {
    locale: localeEntry.identifier,
    slides: localeEntry.scenes.map((scene) => ({
      id: scene.slug,
      eyebrow: scene.eyebrow,
      title: scene.title,
      body: scene.subtitle,
      chips: scene.chips,
      accent: scene.palette.accent,
      accentSoft: scene.palette.accent_soft,
      backgroundTop: scene.palette.background_top,
      backgroundBottom: scene.palette.background_bottom,
      textPrimary: scene.palette.text_primary,
      textSecondary: scene.palette.text_secondary,
      screen: `/raw/${scene.slug}.png`,
    })),
  };
}

function brandSubtitle(locale: string) {
  return locale.startsWith("ko") ? "과거 투자, 현재 가치로 보기" : "Past investing, current value";
}

function deckLabel(locale: string) {
  return locale.startsWith("ko")
    ? `실제 What If Invest 화면 5장 · ${locale}`
    : `Built from 5 real What If Invest screens · ${locale}`;
}

function PhoneMockup({ slide }: { slide: Slide }) {
  return (
    <div style={{ position: "relative", width: 704, aspectRatio: `${MOCKUP_W}/${MOCKUP_H}`, filter: "drop-shadow(0 36px 70px rgba(15,23,42,0.2))" }}>
      <img src="/mockup.png" alt="" draggable={false} style={{ display: "block", width: "100%", height: "100%" }} />
      <div
        style={{
          position: "absolute",
          zIndex: 10,
          overflow: "hidden",
          left: `${SCREEN_LEFT}%`,
          top: `${SCREEN_TOP}%`,
          width: `${SCREEN_WIDTH}%`,
          height: `${SCREEN_HEIGHT}%`,
          borderRadius: `${SCREEN_RX}% / ${SCREEN_RY}%`,
          background: "#FFFFFF",
        }}
      >
        <img
          src={slide.screen}
          alt="What If Invest simulator screenshot"
          draggable={false}
          style={{ display: "block", width: "100%", height: "100%", objectFit: "cover", objectPosition: "top" }}
        />
      </div>
    </div>
  );
}

function SlideCard({ slide, locale }: { slide: Slide; locale: string }) {
  const isKorean = locale.startsWith("ko");

  return (
    <section
      data-slide-id={slide.id}
      style={{
        width: CANVAS_W,
        height: CANVAS_H,
        position: "relative",
        overflow: "hidden",
        background: `linear-gradient(150deg, ${slide.backgroundTop} 0%, ${slide.backgroundBottom} 100%)`,
      }}
    >
      <div style={{ position: "absolute", inset: 0, background: `linear-gradient(90deg, ${slide.accent}14 0%, transparent 42%, ${slide.accentSoft}2E 100%)` }} />

      <div style={{ position: "absolute", top: 86, left: 86, right: 86, display: "flex", justifyContent: "space-between", gap: 34, alignItems: "flex-start" }}>
        <div style={{ width: 760 }}>
          <div style={{ display: "inline-flex", alignItems: "center", gap: 16, padding: "16px 24px", borderRadius: 20, background: "rgba(255,255,255,0.9)", color: slide.accent, fontSize: 25, fontWeight: 800, letterSpacing: 0 }}>
            <span style={{ width: 12, height: 12, borderRadius: 999, background: slide.accent, display: "inline-block" }} />
            {slide.eyebrow}
          </div>

          <h1 style={{ marginTop: 40, marginBottom: 0, fontSize: isKorean ? 88 : 100, lineHeight: isKorean ? 1.12 : 1.02, letterSpacing: 0, fontWeight: 900, color: slide.textPrimary, maxWidth: 760, wordBreak: "keep-all" as const }}>
            {slide.title}
          </h1>

          <p style={{ marginTop: 30, marginBottom: 0, fontSize: isKorean ? 34 : 38, lineHeight: isKorean ? 1.42 : 1.28, letterSpacing: 0, color: slide.textSecondary, maxWidth: 720, fontWeight: 600, wordBreak: "keep-all" as const }}>
            {slide.body}
          </p>

          <div style={{ marginTop: 34, display: "flex", flexWrap: "wrap", gap: 14 }}>
            {slide.chips.map((chip) => (
              <span key={chip} style={{ padding: "16px 22px", borderRadius: 18, background: "rgba(255,255,255,0.92)", fontSize: isKorean ? 25 : 27, fontWeight: 800, color: slide.textPrimary, boxShadow: "inset 0 0 0 1px rgba(17,24,39,0.06)" }}>
                {chip}
              </span>
            ))}
          </div>
        </div>

        <div style={{ textAlign: "right", minWidth: 214 }}>
          <img src="/app-icon.png" alt="What If Invest icon" style={{ width: 136, height: 136, borderRadius: 30, boxShadow: "0 22px 42px rgba(0,82,255,0.18)" }} />
          <div style={{ marginTop: 18, fontSize: 35, fontWeight: 900, color: slide.textPrimary, letterSpacing: 0 }}>What If Invest</div>
          <div style={{ marginTop: 8, fontSize: 22, color: slide.textSecondary, fontWeight: 700 }}>{brandSubtitle(locale)}</div>
        </div>
      </div>

      <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 1190, display: "flex", alignItems: "flex-end", justifyContent: "center" }}>
        <PhoneMockup slide={slide} />
      </div>

      <div style={{ position: "absolute", left: 0, right: 0, bottom: 0, height: 130, background: "linear-gradient(0deg, rgba(255,255,255,0.62), transparent)" }} />
    </section>
  );
}

export default async function Home({
  searchParams,
}: {
  searchParams?: Promise<{ locale?: string | string[] }>;
}) {
  const params = (await searchParams) ?? {};
  const { locale, slides } = await loadSlides(params.locale);

  return (
    <main style={{ minHeight: "100vh", background: "#EDF1F7", overflowX: "hidden", padding: "32px 0 96px" }}>
      <div style={{ width: "fit-content", margin: "0 auto 32px", background: "rgba(255,255,255,0.9)", borderRadius: 20, padding: "14px 24px", color: "#334155", fontWeight: 800, fontSize: 18, boxShadow: "0 10px 30px rgba(15,23,42,0.08)" }}>
        {deckLabel(locale)}
      </div>
      <div style={{ display: "grid", gap: 28, justifyContent: "center" }}>
        {slides.map((slide) => <SlideCard key={slide.id} slide={slide} locale={locale} />)}
      </div>
    </main>
  );
}
