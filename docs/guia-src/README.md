# Fonte do Guia do Aluno

`build.js` + `lib.js` geram `docs/Guia-do-Aluno.docx` com a biblioteca `docx` (Node.js). O PDF é exportado pelo Word, que também preenche o sumário.

```powershell
cd docs/guia-src
npm install docx@9
node build.js ../Guia-do-Aluno.docx
# abrir o .docx no Word: Ctrl+A, F9 (atualiza o sumário) e Salvar como PDF
```

Ao mudar conteúdo dos guias (`aulas/*/GUIA.md`, `docs/*.md`), atualize o texto correspondente em `build.js` e regenere.
