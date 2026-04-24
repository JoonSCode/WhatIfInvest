import { chromium } from 'playwright';
import fs from 'node:fs/promises';
import path from 'node:path';

const port = process.env.WHATIFINVEST_MARKETING_PORT ?? '3010';
const outDir = process.env.WHATIFINVEST_GENERATED_OUTPUT ?? '/tmp/whatifinvest-marketing-generator-output';
const locale = process.env.WHATIFINVEST_MARKETING_LOCALE ?? 'en-US';
await fs.mkdir(outDir, { recursive: true });

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: 1500, height: 1000 }, deviceScaleFactor: 1 });
await page.goto(`http://127.0.0.1:${port}/?locale=${encodeURIComponent(locale)}`, { waitUntil: 'networkidle' });

const slides = await page.locator('[data-slide-id]').evaluateAll((nodes) =>
  nodes.map((node) => node.getAttribute('data-slide-id')).filter(Boolean)
);

for (const id of slides) {
  const locator = page.locator(`[data-slide-id="${id}"]`);
  await locator.screenshot({ path: path.join(outDir, `${id}.png`) });
}

await browser.close();
console.log(JSON.stringify({ outDir, locale, slides }, null, 2));
