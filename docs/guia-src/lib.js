// Formatação do Guia do Aluno (docx-js), no padrão visual dos roteiros da disciplina:
// Arial, títulos em azul institucional, destaques em dourado, cabeçalho com a marca
// e rodapé numerado. As medidas seguem o "Roteiro de Atividade Prática de Big Data".
const fs = require("fs");
const path = require("path");
const d = require("docx");
const {
  Paragraph, TextRun, HeadingLevel, AlignmentType, Table, TableRow, TableCell,
  WidthType, ShadingType, BorderStyle, PageBreak, ExternalHyperlink, ImageRun,
  Header, Footer, PageNumber, VerticalAlign,
} = d;

// ---- paleta e métricas do padrão institucional ----
const FONT = "Arial";
const MONO = "Consolas";
const BLUE = "113162";       // azul dos títulos
const GOLD = "F5A607";       // dourado dos filetes e do número de página
const LINK = "0563C1";
const GREY = "F2F2F2";
const CODE_BG = "F4F4F4";
const HEAD_BG = "113162";    // cabeçalho de tabela: azul com texto branco
const NOTE_BG = "FFF6E0";
const NOTE_BRD = "F5A607";
const PAGE_W = 11906;        // A4
const PAGE_H = 16838;
const MARGIN = 1080;         // esquerda/direita (1,9 cm)
const MARGIN_V = 1440;       // topo/base (2,54 cm)
const TEXT_W = PAGE_W - 2 * MARGIN; // 9746
const BODY = 22;             // Arial 11

const ASSETS = path.join(__dirname, "assets");
const img = (f) => fs.readFileSync(path.join(ASSETS, f));

// ---- inline: converte "texto com `codigo`, **negrito** e [rótulo](url)" em TextRuns ----
function link(label, url, base = {}) {
  const bruto = label === url || /^https?:\/\//.test(label);
  return new ExternalHyperlink({
    link: url,
    children: [new TextRun({
      text: label, font: bruto ? MONO : FONT, size: bruto ? 18 : BODY,
      color: LINK, underline: {}, ...base,
    })],
  });
}

function runs(text, base = {}) {
  const out = [];
  const re = /(\[[^\]]+\]\((https?:\/\/[^)\s]+)\)|`[^`]+`|\*\*[^*]+\*\*|https?:\/\/[^\s)`,;]+)/g;
  let last = 0, m;
  while ((m = re.exec(text)) !== null) {
    if (m.index > last) out.push(new TextRun({ text: text.slice(last, m.index), font: FONT, size: BODY, ...base }));
    const tok = m[0];
    if (tok.startsWith("[")) {
      const mm = /^\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)$/.exec(tok);
      out.push(link(mm[1], mm[2], base));
    } else if (tok.startsWith("`")) {
      out.push(new TextRun({
        text: tok.slice(1, -1), font: MONO, size: 18,
        shading: { type: ShadingType.CLEAR, fill: "EDEDED", color: "auto" }, ...base,
      }));
    } else if (tok.startsWith("**")) {
      out.push(new TextRun({ text: tok.slice(2, -2), font: FONT, size: BODY, bold: true, ...base }));
    } else {
      out.push(link(tok, tok, base));
    }
    last = m.index + tok.length;
  }
  if (last < text.length) out.push(new TextRun({ text: text.slice(last), font: FONT, size: BODY, ...base }));
  return out;
}

const P = (text, opts = {}) => new Paragraph({
  children: runs(text, opts.run || {}),
  alignment: AlignmentType.JUSTIFIED,
  spacing: { after: 140, line: 288 },
  ...opts.para,
});

// H1 centralizado e em caixa alta, como nos roteiros da disciplina
const H1 = (text) => new Paragraph({ text: text.toUpperCase(), heading: HeadingLevel.HEADING_1, pageBreakBefore: true });
const H1n = (text) => new Paragraph({ text: text.toUpperCase(), heading: HeadingLevel.HEADING_1 });
const H2 = (text) => new Paragraph({ text, heading: HeadingLevel.HEADING_2 });
const H3 = (text) => new Paragraph({ text, heading: HeadingLevel.HEADING_3 });

// bloco de código: um parágrafo por linha, fundo cinza, filete azul à esquerda
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
  alignment: AlignmentType.JUSTIFIED, spacing: { after: 80, line: 280 },
});
const Num = (text, ref = "steps", level = 0) => new Paragraph({
  children: runs(text), numbering: { reference: ref, level },
  alignment: AlignmentType.JUSTIFIED, spacing: { after: 80, line: 280 },
});

// caixa de destaque
function Note(title, text) {
  return new Table({
    width: { size: TEXT_W, type: WidthType.DXA }, columnWidths: [TEXT_W],
    rows: [new TableRow({ cantSplit: true, children: [new TableCell({
      width: { size: TEXT_W, type: WidthType.DXA },
      shading: { type: ShadingType.CLEAR, fill: NOTE_BG, color: "auto" },
      margins: { top: 120, bottom: 120, left: 160, right: 160 },
      borders: {
        top: { style: BorderStyle.SINGLE, size: 4, color: NOTE_BRD },
        bottom: { style: BorderStyle.SINGLE, size: 4, color: NOTE_BRD },
        left: { style: BorderStyle.SINGLE, size: 18, color: NOTE_BRD },
        right: { style: BorderStyle.SINGLE, size: 4, color: NOTE_BRD },
      },
      children: [
        new Paragraph({ children: [new TextRun({ text: title, bold: true, font: FONT, size: BODY, color: BLUE })], spacing: { after: 60 } }),
        ...(Array.isArray(text) ? text : [text]).map(t => new Paragraph({
          children: runs(t), alignment: AlignmentType.JUSTIFIED, spacing: { after: 40, line: 272 },
        })),
      ],
    })] })],
  });
}

// tabela: cabeçalho azul com texto branco; larguras em proporção
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
    verticalAlign: VerticalAlign.CENTER,
    children: [new Paragraph({
      children: runs(String(txt), head ? { bold: true, color: "FFFFFF" } : {}),
      alignment: AlignmentType.LEFT, spacing: { after: 0, line: 256 },
    })],
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
const TblS = (h, r, w) => [Tbl(h, r, w), Spacer(100)];

// ---- capa no padrão institucional ----
function Capa(titulo, subtitulo, linha3, autor, ano) {
  const caixaAno = new Table({
    width: { size: 1100, type: WidthType.DXA }, columnWidths: [1100],
    alignment: AlignmentType.RIGHT,
    rows: [new TableRow({ children: [new TableCell({
      width: { size: 1100, type: WidthType.DXA },
      shading: { type: ShadingType.CLEAR, fill: "FCE3B0", color: "auto" },
      margins: { top: 80, bottom: 80, left: 100, right: 100 },
      borders: { top: { style: BorderStyle.NONE }, bottom: { style: BorderStyle.NONE }, left: { style: BorderStyle.NONE }, right: { style: BorderStyle.NONE } },
      children: [
        new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 20 }, children: [new TextRun({ text: "ANO", bold: true, font: FONT, size: 20, color: "000000" })] }),
        new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: String(ano), bold: true, font: FONT, size: 20, color: "000000" })] }),
      ],
    })] })],
  });

  const faixa = new Table({
    width: { size: TEXT_W, type: WidthType.DXA }, columnWidths: [TEXT_W],
    rows: [new TableRow({ children: [new TableCell({
      width: { size: TEXT_W, type: WidthType.DXA },
      shading: { type: ShadingType.CLEAR, fill: BLUE, color: "auto" },
      margins: { top: 160, bottom: 160, left: 200, right: 240 },
      borders: {
        top: { style: BorderStyle.SINGLE, size: 24, color: GOLD },
        bottom: { style: BorderStyle.NONE }, left: { style: BorderStyle.NONE }, right: { style: BorderStyle.NONE },
      },
      children: [
        new Paragraph({ alignment: AlignmentType.RIGHT, spacing: { after: 40 }, children: [new TextRun({ text: "Material elaborado por:", bold: true, font: FONT, size: 22, color: "FFFFFF" })] }),
        new Paragraph({ alignment: AlignmentType.RIGHT, children: [new TextRun({ text: autor, bold: true, font: FONT, size: 22, color: "FFFFFF" })] }),
      ],
    })] })],
  });

  const t = (texto, cor, tam) => new Paragraph({
    alignment: AlignmentType.CENTER, spacing: { after: 120 },
    children: [new TextRun({ text: texto, bold: true, font: FONT, size: tam, color: cor })],
  });

  return [
    caixaAno,
    Spacer(700),
    new Paragraph({
      alignment: AlignmentType.CENTER, spacing: { after: 100 },
      children: [new ImageRun({ type: "png", data: img("uninter-logo.png"), transformation: { width: 300, height: 300 } })],
    }),
    t(titulo.toUpperCase(), BLUE, 44),
    t(subtitulo.toUpperCase(), GOLD, 36),
    Spacer(260),
    t(linha3.toUpperCase(), BLUE, 40),
    Spacer(3100),
    faixa,
  ];
}

// ---- cabeçalho e rodapé das páginas internas ----
function Cabecalho(titulo) {
  const linhas = Array.isArray(titulo) ? titulo : [titulo];
  const meia = Math.round(TEXT_W / 2);
  return new Header({ children: [
    new Table({
      width: { size: TEXT_W, type: WidthType.DXA }, columnWidths: [meia, TEXT_W - meia],
      borders: {
        top: { style: BorderStyle.NONE }, bottom: { style: BorderStyle.NONE },
        left: { style: BorderStyle.NONE }, right: { style: BorderStyle.NONE },
        insideHorizontal: { style: BorderStyle.NONE }, insideVertical: { style: BorderStyle.NONE },
      },
      rows: [new TableRow({ children: [
        new TableCell({
          width: { size: meia, type: WidthType.DXA }, margins: { top: 0, bottom: 0, left: 0, right: 120 },
          verticalAlign: VerticalAlign.CENTER,
          children: [new Paragraph({ spacing: { after: 0 }, children: [
            new ImageRun({ type: "png", data: img("uninter-header.png"), transformation: { width: 236, height: 49 } }),
          ] })],
        }),
        new TableCell({
          width: { size: TEXT_W - meia, type: WidthType.DXA }, margins: { top: 0, bottom: 0, left: 120, right: 0 },
          verticalAlign: VerticalAlign.CENTER,
          children: linhas.map((l, i) => new Paragraph({
            spacing: { after: 0, line: 240 },
            children: [new TextRun({ text: l, font: FONT, size: 18, color: BLUE, bold: i === 0 })],
          })),
        }),
      ] })],
    }),
    new Paragraph({
      spacing: { before: 60, after: 0 }, text: "",
      border: { bottom: { style: BorderStyle.SINGLE, size: 12, color: GOLD, space: 2 } },
    }),
  ] });
}

function Rodape() {
  return new Footer({ children: [new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 0, after: 0 },
    border: { top: { style: BorderStyle.SINGLE, size: 8, color: BLUE, space: 6 } },
    children: [new TextRun({ children: [PageNumber.CURRENT], font: FONT, size: 18, bold: true, color: GOLD })],
  })] });
}

const Vazio = (Cls) => new Cls({ children: [new Paragraph({ text: "" })] });

// estilos de título usados pelo sumário automático do Word
const estilosTitulo = [
  { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
    run: { font: FONT, size: 32, bold: true, color: BLUE },
    paragraph: { spacing: { before: 240, after: 240 }, outlineLevel: 0, alignment: AlignmentType.CENTER } },
  { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
    run: { font: FONT, size: 24, bold: true, color: BLUE },
    paragraph: { spacing: { before: 280, after: 120 }, outlineLevel: 1 } },
  { id: "Heading3", name: "Heading 3", basedOn: "Normal", next: "Normal", quickFormat: true,
    run: { font: FONT, size: 22, bold: true, color: "000000" },
    paragraph: { spacing: { before: 200, after: 80 }, outlineLevel: 2 } },
];

module.exports = {
  d, fs, path,
  FONT, MONO, BLUE, GOLD, LINK, GREY, HEAD_BG, NOTE_BG, BODY,
  PAGE_W, PAGE_H, MARGIN, MARGIN_V, TEXT_W,
  runs, link, P, H1, H1n, H2, H3, Code, Bullet, Num, Note, Tbl, TblS, Spacer, Break,
  Capa, Cabecalho, Rodape, Vazio, estilosTitulo, img,
};
