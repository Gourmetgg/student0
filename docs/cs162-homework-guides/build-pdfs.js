const fs = require("fs");
const path = require("path");
const { pathToFileURL } = require("url");
const { spawnSync } = require("child_process");

const repoRoot = path.resolve(__dirname, "..", "..");
const outDir = __dirname;

const markdownSources = [
  ["Repository Overview", "README.md"],
  ["HW 0 Intro", "hw-intro/README.md"],
  ["HW 1 Lists", "hw-list/README.md"],
  ["HW 2 Shell", "hw-shell/README.md"],
  ["HW 3 HTTP C", "hw-http/README.md"],
  ["HW 3 HTTP Rust", "hw-http-rs/README.md"],
  ["HW 4 Memory", "hw-memory/README.md"],
  ["HW 5 MapReduce C", "hw-map-reduce/README.md"],
  ["HW 5 MapReduce Rust", "hw-map-reduce-rs/README.md"],
];

function readRepoFile(relativePath) {
  return fs.readFileSync(path.join(repoRoot, relativePath), "utf8");
}

function writeFile(name, content) {
  const filePath = path.join(outDir, name);
  fs.writeFileSync(filePath, content, "utf8");
  return filePath;
}

function buildCompanionMarkdown() {
  const chunks = [
    "CS 162 Homework Companion Guide",
    "=================================",
    "",
    "Generated from the repository README files.",
    "",
    "This guide is an original, repository-specific companion to the public CS 162 homework pages. It does not copy the official pages verbatim; instead, it maps the official task structure to this repository, adds build and run commands, and includes detailed testing guidance.",
    "",
  ];

  for (const [title, relativePath] of markdownSources) {
    chunks.push("");
    chunks.push("");
    chunks.push(title);
    chunks.push("=".repeat(title.length));
    chunks.push("");
    chunks.push(`Source file: \`${relativePath}\``);
    chunks.push("");
    chunks.push(readRepoFile(relativePath).trim());
  }

  chunks.push("");
  chunks.push("");
  chunks.push("Test Completeness Audit");
  chunks.push("=======================");
  chunks.push("");
  chunks.push("The standalone audit is included as a separate document and PDF:");
  chunks.push("");
  chunks.push("- `test-completeness-audit.md`");
  chunks.push("- `test-completeness-audit.pdf`");
  chunks.push("");

  return chunks.join("\n");
}

function escapeHtml(value) {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

function inlineMarkdown(value) {
  return escapeHtml(value)
    .replace(/`([^`]+)`/g, "<code>$1</code>")
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>')
    .replace(/&lt;(https?:\/\/[^&]+)&gt;/g, '<a href="$1">$1</a>');
}

function renderMarkdown(markdown, title) {
  const lines = markdown.replace(/\r\n/g, "\n").split("\n");
  const html = [];
  let paragraph = [];
  let inCode = false;
  let codeLines = [];
  let listType = null;
  let tableLines = [];

  function flushParagraph() {
    if (paragraph.length) {
      html.push(`<p>${inlineMarkdown(paragraph.join(" "))}</p>`);
      paragraph = [];
    }
  }

  function flushList() {
    if (listType) {
      html.push(`</${listType}>`);
      listType = null;
    }
  }

  function flushTable() {
    if (!tableLines.length) return;
    const rows = tableLines
      .filter((line) => !/^\|\s*-+/.test(line))
      .map((line) =>
        line
          .trim()
          .replace(/^\||\|$/g, "")
          .split("|")
          .map((cell) => inlineMarkdown(cell.trim()))
      );
    html.push("<table>");
    rows.forEach((cells, index) => {
      html.push("<tr>");
      for (const cell of cells) {
        html.push(index === 0 ? `<th>${cell}</th>` : `<td>${cell}</td>`);
      }
      html.push("</tr>");
    });
    html.push("</table>");
    tableLines = [];
  }

  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];
    const next = lines[i + 1] || "";

    if (line.startsWith("```")) {
      flushParagraph();
      flushList();
      flushTable();
      if (inCode) {
        html.push(`<pre><code>${escapeHtml(codeLines.join("\n"))}</code></pre>`);
        codeLines = [];
        inCode = false;
      } else {
        inCode = true;
      }
      continue;
    }

    if (inCode) {
      codeLines.push(line);
      continue;
    }

    if (/^\|.*\|$/.test(line.trim())) {
      flushParagraph();
      flushList();
      tableLines.push(line);
      continue;
    } else {
      flushTable();
    }

    if (/^=+$/.test(next.trim()) && line.trim()) {
      flushParagraph();
      flushList();
      html.push(`<h1>${inlineMarkdown(line.trim())}</h1>`);
      i += 1;
      continue;
    }

    if (/^-+$/.test(next.trim()) && line.trim()) {
      flushParagraph();
      flushList();
      html.push(`<h2>${inlineMarkdown(line.trim())}</h2>`);
      i += 1;
      continue;
    }

    const atx = /^(#{1,6})\s+(.+)$/.exec(line);
    if (atx) {
      flushParagraph();
      flushList();
      const level = Math.min(atx[1].length, 4);
      html.push(`<h${level}>${inlineMarkdown(atx[2].trim())}</h${level}>`);
      continue;
    }

    const bullet = /^\s*[-*]\s+(.+)$/.exec(line);
    const numbered = /^\s*\d+\.\s+(.+)$/.exec(line);
    if (bullet || numbered) {
      flushParagraph();
      const desiredType = bullet ? "ul" : "ol";
      if (listType !== desiredType) {
        flushList();
        listType = desiredType;
        html.push(`<${listType}>`);
      }
      html.push(`<li>${inlineMarkdown((bullet || numbered)[1].trim())}</li>`);
      continue;
    }

    if (!line.trim()) {
      flushParagraph();
      flushList();
      continue;
    }

    paragraph.push(line.trim());
  }

  flushParagraph();
  flushList();
  flushTable();

  return `<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>${escapeHtml(title)}</title>
  <style>
    @page { margin: 0.72in; }
    body {
      color: #1f2937;
      font-family: "Segoe UI", Arial, sans-serif;
      font-size: 11.5pt;
      line-height: 1.48;
      max-width: 920px;
      margin: 0 auto;
    }
    h1 {
      color: #111827;
      font-size: 23pt;
      line-height: 1.15;
      margin: 28px 0 12px;
      page-break-after: avoid;
    }
    h2 {
      border-bottom: 1px solid #d1d5db;
      color: #111827;
      font-size: 16pt;
      margin: 24px 0 10px;
      padding-bottom: 4px;
      page-break-after: avoid;
    }
    h3, h4 {
      color: #111827;
      margin: 18px 0 8px;
      page-break-after: avoid;
    }
    p { margin: 7px 0; }
    ul, ol { margin: 7px 0 12px 24px; padding: 0; }
    li { margin: 3px 0; }
    code {
      background: #f3f4f6;
      border: 1px solid #e5e7eb;
      border-radius: 4px;
      font-family: Consolas, "Liberation Mono", monospace;
      font-size: 0.92em;
      padding: 1px 4px;
    }
    pre {
      background: #111827;
      border-radius: 6px;
      color: #f9fafb;
      overflow-wrap: anywhere;
      padding: 11px 13px;
      white-space: pre-wrap;
    }
    pre code {
      background: transparent;
      border: 0;
      color: inherit;
      padding: 0;
    }
    table {
      border-collapse: collapse;
      margin: 12px 0;
      width: 100%;
    }
    th, td {
      border: 1px solid #d1d5db;
      padding: 6px 8px;
      text-align: left;
      vertical-align: top;
    }
    th {
      background: #f3f4f6;
      color: #111827;
    }
    a { color: #0f766e; text-decoration: none; }
  </style>
</head>
<body>
${html.join("\n")}
</body>
</html>`;
}

function findBrowsers() {
  return [
    process.env.CHROME_PATH,
    "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
    "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
    "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe",
    "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
  ].filter(Boolean).filter((candidate, index, list) =>
    fs.existsSync(candidate) && list.indexOf(candidate) === index
  );
}

function printPdf(htmlPath, pdfPath) {
  const browsers = findBrowsers();
  if (!browsers.length) {
    console.log(`No Chrome or Edge found; skipped PDF for ${path.basename(htmlPath)}.`);
    return false;
  }

  const args = [
    "--headless=new",
    "--disable-gpu",
    "--disable-gpu-compositing",
    "--disable-software-rasterizer",
    "--disable-dev-shm-usage",
    "--disable-extensions",
    "--no-first-run",
    "--no-default-browser-check",
    "--no-pdf-header-footer",
    `--print-to-pdf=${pdfPath}`,
    pathToFileURL(htmlPath).href,
  ];

  for (const browser of browsers) {
    const result = spawnSync(browser, args, { encoding: "utf8" });
    if (result.status === 0 && fs.existsSync(pdfPath)) {
      return true;
    }
    console.log(`PDF attempt failed with ${browser}; falling back if no browser succeeds.`);
  }

  return false;
}

function markdownToPlainLines(markdown) {
  const lines = [];
  let inCode = false;

  for (const rawLine of markdown.replace(/\r\n/g, "\n").split("\n")) {
    if (rawLine.startsWith("```")) {
      inCode = !inCode;
      lines.push("");
      continue;
    }

    let line = rawLine;
    if (!inCode) {
      line = line
        .replace(/^#{1,6}\s+/, "")
        .replace(/^\s*[-*]\s+/, "- ")
        .replace(/^\s*(\d+)\.\s+/, "$1. ")
        .replace(/\[([^\]]+)\]\(([^)]+)\)/g, "$1 <$2>")
        .replace(/`([^`]+)`/g, "$1")
        .replace(/\*\*([^*]+)\*\*/g, "$1");
    }
    lines.push(line);
  }

  return lines;
}

function wrapLine(line, width) {
  if (!line.trim()) return [""];
  const result = [];
  let current = "";
  for (const word of line.split(/\s+/)) {
    if (!current) {
      current = word;
    } else if ((current + " " + word).length <= width) {
      current += " " + word;
    } else {
      result.push(current);
      current = word;
    }
  }
  if (current) result.push(current);
  return result;
}

function escapePdfText(value) {
  return value
    .replace(/\\/g, "\\\\")
    .replace(/\(/g, "\\(")
    .replace(/\)/g, "\\)")
    .replace(/[^\x09\x0A\x0D\x20-\x7E]/g, "?");
}

function writePlainTextPdf(markdown, pdfPath, title) {
  const pageWidth = 612;
  const pageHeight = 792;
  const marginX = 48;
  const startY = 744;
  const lineHeight = 12;
  const maxLines = 58;
  const maxChars = 92;
  const pages = [];
  let current = [];

  const plainLines = [
    title,
    "=".repeat(title.length),
    "",
    "Fallback PDF generated by build-pdfs.js because browser PDF printing was unavailable.",
    "",
    ...markdownToPlainLines(markdown),
  ];

  for (const line of plainLines) {
    for (const wrapped of wrapLine(line, maxChars)) {
      current.push(wrapped);
      if (current.length >= maxLines) {
        pages.push(current);
        current = [];
      }
    }
  }
  if (current.length) pages.push(current);

  const objects = [];
  function addObject(body) {
    objects.push(body);
    return objects.length;
  }

  const catalogId = addObject("<< /Type /Catalog /Pages 2 0 R >>");
  const pagesId = addObject("");
  const fontId = addObject("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");
  const pageIds = [];

  for (const pageLines of pages) {
    const content = [
      "BT",
      "/F1 9 Tf",
      `${lineHeight} TL`,
      `${marginX} ${startY} Td`,
      ...pageLines.map((line) => `(${escapePdfText(line)}) Tj T*`),
      "ET",
    ].join("\n");
    const contentId = addObject(`<< /Length ${Buffer.byteLength(content, "utf8")} >>\nstream\n${content}\nendstream`);
    const pageId = addObject(`<< /Type /Page /Parent ${pagesId} 0 R /MediaBox [0 0 ${pageWidth} ${pageHeight}] /Resources << /Font << /F1 ${fontId} 0 R >> >> /Contents ${contentId} 0 R >>`);
    pageIds.push(pageId);
  }

  objects[pagesId - 1] = `<< /Type /Pages /Kids [${pageIds.map((id) => `${id} 0 R`).join(" ")}] /Count ${pageIds.length} >>`;

  let pdf = "%PDF-1.4\n";
  const offsets = [0];
  for (let i = 0; i < objects.length; i += 1) {
    offsets.push(Buffer.byteLength(pdf, "utf8"));
    pdf += `${i + 1} 0 obj\n${objects[i]}\nendobj\n`;
  }
  const xrefOffset = Buffer.byteLength(pdf, "utf8");
  pdf += `xref\n0 ${objects.length + 1}\n`;
  pdf += "0000000000 65535 f \n";
  for (let i = 1; i < offsets.length; i += 1) {
    pdf += `${String(offsets[i]).padStart(10, "0")} 00000 n \n`;
  }
  pdf += `trailer\n<< /Size ${objects.length + 1} /Root ${catalogId} 0 R >>\nstartxref\n${xrefOffset}\n%%EOF\n`;

  fs.writeFileSync(pdfPath, pdf, "binary");
}

function buildDocument(markdownPath, htmlName, pdfName, title) {
  const markdown = fs.readFileSync(markdownPath, "utf8");
  const htmlPath = writeFile(htmlName, renderMarkdown(markdown, title));
  const pdfPath = path.join(outDir, pdfName);
  if (!printPdf(htmlPath, pdfPath)) {
    writePlainTextPdf(markdown, pdfPath, title);
    console.log(`Wrote fallback text PDF for ${pdfName}.`);
  }
  return { markdownPath, htmlPath, pdfPath };
}

fs.mkdirSync(outDir, { recursive: true });

const companionMarkdown = buildCompanionMarkdown();
const companionPath = writeFile("cs162-homework-companion.md", companionMarkdown);

const companion = buildDocument(
  companionPath,
  "cs162-homework-companion.html",
  "cs162-homework-companion.pdf",
  "CS 162 Homework Companion Guide"
);

const audit = buildDocument(
  path.join(outDir, "test-completeness-audit.md"),
  "test-completeness-audit.html",
  "test-completeness-audit.pdf",
  "CS 162 Homework Test Completeness Audit"
);

console.log("Generated:");
for (const item of [companion, audit]) {
  console.log(`- ${path.relative(repoRoot, item.markdownPath)}`);
  console.log(`- ${path.relative(repoRoot, item.htmlPath)}`);
  if (fs.existsSync(item.pdfPath)) {
    console.log(`- ${path.relative(repoRoot, item.pdfPath)}`);
  }
}
