#!/usr/bin/env bash
# Cloudflare Pages 용 정적 빌드: index.md / support.md → public/
# 배포: ./build.sh && npx wrangler deploy   (Cloudflare Workers static assets → autoscroll-privacy.straynurbs.workers.dev)
set -euo pipefail
cd "$(dirname "$0")"

rm -rf public
mkdir -p public/support

render() {
  local src="$1" out="$2" title="$3"
  # Jekyll front matter(--- ... ---) 제거 후 마크다운 → HTML
  local body
  body=$(awk 'NR==1 && /^---$/ {fm=1; next} fm && /^---$/ {fm=0; next} !fm' "$src" | npx --yes marked --gfm)
  cat > "$out" <<HTML
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title}</title>
<style>
  :root { color-scheme: light dark; --fg:#1d1d1f; --muted:#6e6e73; --bg:#fff; --line:#e5e5ea; --accent:#0a84ff; }
  @media (prefers-color-scheme: dark) { :root { --fg:#f5f5f7; --muted:#a1a1a6; --bg:#111; --line:#2c2c2e; } }
  body { margin:0; background:var(--bg); color:var(--fg); font:16px/1.7 -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo", "Hiragino Sans", "Noto Sans KR", sans-serif; }
  main { max-width:760px; margin:0 auto; padding:40px 20px 80px; }
  nav { font-size:14px; margin-bottom:24px; } nav a { margin-right:16px; }
  h1 { font-size:26px; line-height:1.35; } h2 { margin-top:48px; padding-bottom:6px; border-bottom:1px solid var(--line); }
  h3 { margin-top:32px; } h4 { margin-top:20px; color:var(--muted); }
  a { color:var(--accent); } hr { border:0; border-top:1px solid var(--line); margin:40px 0; }
  code { font-size:.9em; }
</style>
</head>
<body><main>
<nav><a href="/">Privacy Policy</a><a href="/support/">Support</a></nav>
${body}
</main></body>
</html>
HTML
}

render index.md   public/index.html         "AutoScroll 개인정보처리방침 / Privacy Policy"
render support.md public/support/index.html "AutoScroll Support"

# 옛 GitHub Pages 경로(/support.html) 호환
printf '/support.html /support/ 301\n' > public/_redirects

echo "built → public/"
