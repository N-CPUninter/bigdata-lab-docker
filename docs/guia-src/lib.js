// Helpers de formatação para o Guia do Aluno (docx-js).
const d = require("docx");
const {
  Paragraph, TextRun, HeadingLevel, AlignmentType, Table, TableRow, TableCell,
  WidthType, ShadingType, BorderStyle, PageBreak, TabStopType, ExternalHyperlink,
} = d;

const FONT = "Calibri";
const MONO = "Consolas";
const BLUE = "1B3A5C";
const GREY = "F2F2F2";
const CODE_BG = "F4F4F4";
const HEAD_BG = "D9E2F3";
const NOTE_BG = "FFF8E1";
const PAGE_W = 11906; // A4
const MARGIN = 1418;  // 2,5 cm
const TEXT_W = PAGE_W - 2 * MARGIN; // 9070

// ---- inline: converte "texto com `codigo` e **negrito**" em TextRuns ----
function link(label, url, base = {}) {
  return new ExternalHyperlink({ link: url, children: [new TextRun({ text: label, font: (label === url || /^https?:\/\//.test(label)) ? MONO : FONT, size: (label === url || /^https?:\/\//.test(label)) ? 19 : 22, color: "0563C1", underline: {}, ...base })] });
}
function runs(text, base = {}) {
  const out = [];
  // tokens: [rotulo](url) | `codigo` | **negrito** | URL solta
  const re = /(\[[^\]]+\]\((https?:\/\/[^)\s]+)\)|`[^`]+`|\*\*[^*]+\*\*|https?:\/\/[^\s)`,;]+)/g;
  let last = 0, m;
  while ((m = re.exec(text)) !== null) {
    if (m.index > last) out.push(new TextRun({ text: text.slice(last, m.index), font: FONT, size: 22, ...base }));
    const tok = m[0];
    if (tok.startsWith("[")) { const mm = /^\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)$/.exec(tok); out.push(link(mm[1], mm[2], base)); }
    else if (tok.startsWith("`")) out.push(new TextRun({ text: tok.slice(1, -1), font: MONO, size: 19, shading: { type: ShadingType.CLEAR, fill: "EDEDED", color: "auto" }, ...base }));
    else if (tok.startsWith("**")) out.push(new TextRun({ text: tok.slice(2, -2), font: FONT, size: 22, bold: true, ...base }));
    else out.push(link(tok, tok, base));
    last = m.index + tok.length;
  }
  if (last < text.length) out.push(new TextRun({ text: text.slice(last), font: FONT, size: 22, ...base }));
  return out;
}

const P = (text, opts = {}) => new Paragraph({
  children: runs(text, opts.run || {}),
  alignment: AlignmentType.JUSTIFIED,
  spacing: { after: 140, line: 300 },
  ...opts.para,
});

const H1 = (text) => new Paragraph({ text, heading: HeadingLevel.HEADING_1, spacing: { before: 360, after: 200 }, pageBreakBefore: true });
const H1n = (text) => new Paragraph({ text, heading: HeadingLevel.HEADING_1, spacing: { before: 360, after: 200 } });
const H2 = (text) => new Paragraph({ text, heading: HeadingLevel.HEADING_2, spacing: { before: 280, after: 140 } });
const H3 = (text) => new Paragraph({ text, heading: HeadingLevel.HEADING_3, spacing: { before: 200, after: 100 } });

// bloco de código: um parágrafo por linha, fundo cinza, fonte mono
function Code(lines) {
  const arr = Array.isArray(lines) ? lines : lines.split("\n");
  return arr.map((l, i) => new Paragraph({
    children: [new TextRun({ text: l.length ? l : " ", font: MONO, size: 17 })],
    shading: { type: ShadingType.CLEAR, fill: CODE_BG, color: "auto" },
    spacing: { before: i === 0 ? 60 : 0, after: i === arr.length - 1 ? 160 : 0, line: 260 },
    indent: { left: 200, right: 200 },
    border: {
      left: { style: BorderStyle.SINGLE, size: 12, color: BLUE, space: 8 },
      ...(i === 0 ? { top: { style: BorderStyle.SINGLE, size: 4, color: "CCCCCC", space: 4 } } : {}),
      ...(i === arr.length - 1 ? { bottom: { style: BorderStyle.SINGLE, size: 4, color: "CCCCCC", space: 4 } } : {}),
    },
    keepNext: i < arr.length - 1,
    keepLines: true,
  }));
}

const Bullet = (text, level = 0) => new Paragraph({
  children: runs(text), numbering: { reference: "bullets", level },
  alignment: AlignmentType.JUSTIFIED, spacing: { after: 80, line: 290 },
});
const Num = (text, ref = "steps", level = 0) => new Paragraph({
  children: runs(text), numbering: { reference: ref, level },
  alignment: AlignmentType.JUSTIFIED, spacing: { after: 80, line: 290 },
});

// caixa de destaque (nota / atenção)
function Note(title, text) {
  return new Table({
    width: { size: TEXT_W, type: WidthType.DXA }, columnWidths: [TEXT_W],
    rows: [new TableRow({ cantSplit: true, children: [new TableCell({
      width: { size: TEXT_W, type: WidthType.DXA },
      shading: { type: ShadingType.CLEAR, fill: NOTE_BG, color: "auto" },
      margins: { top: 120, bottom: 120, left: 160, right: 160 },
      borders: {
        top: { style: BorderStyle.SINGLE, size: 4, color: "E0C060" }, bottom: { style: BorderStyle.SINGLE, size: 4, color: "E0C060" },
        left: { style: BorderStyle.SINGLE, size: 18, color: "E0A000" }, right: { style: BorderStyle.SINGLE, size: 4, color: "E0C060" },
      },
      children: [
        new Paragraph({ children: [new TextRun({ text: title, bold: true, font: FONT, size: 22, color: "7A4E00" })], spacing: { after: 60 } }),
        ...(Array.isArray(text) ? text : [text]).map(t => new Paragraph({ children: runs(t), alignment: AlignmentType.JUSTIFIED, spacing: { after: 40, line: 280 } })),
      ],
    })] })],
  });
}

// tabela simples: header (array) + rows (array de arrays); widths em proporção
function Tbl(header, rows, widths) {
  const n = header.length;
  const w = widths || Array(n).fill(1);
  const tot = w.reduce((a, b) => a + b, 0);
  const cols = w.map(x => Math.round(TEXT_W * x / tot));
  cols[cols.length - 1] += TEXT_W - cols.reduce((a, b) => a + b, 0);
  const border = { style: BorderStyle.SINGLE, size: 4, color: "BFBFBF" };
  const borders = { top: border, bottom: border, left: border, right: border };
  const cell = (txt, i, head) => new TableCell({
    width: { size: cols[i], type: WidthType.DXA }, borders,
    shading: head ? { type: ShadingType.CLEAR, fill: HEAD_BG, color: "auto" } : undefined,
    margins: { top: 60, bottom: 60, left: 100, right: 100 },
    children: [new Paragraph({ children: runs(String(txt), head ? { bold: true } : {}).map(r => r), alignment: AlignmentType.LEFT, spacing: { after: 0, line: 260 } })],
  });
  return new Table({
    width: { size: TEXT_W, type: WidthType.DXA }, columnWidths: cols,
    rows: [
      new TableRow({ tableHeader: true, children: header.map((h, i) => cell(h, i, true)) }),
      ...rows.map(r => new TableRow({ children: r.map((c, i) => cell(c, i, false)) })),
    ],
  });
}

const Spacer = (after = 120) => new Paragraph({ text: "", spacing: { after } });
const Break = () => new Paragraph({ children: [new PageBreak()] });

const TblS = (h,r,w) => [Tbl(h,r,w), Spacer(100)];
module.exports = { TblS, link, d, FONT, MONO, BLUE, GREY, TEXT_W, PAGE_W, MARGIN, runs, P, H1, H1n, H2, H3, Code, Bullet, Num, Note, Tbl, Spacer, Break };
