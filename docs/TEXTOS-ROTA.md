# Textos prontos para a rota e para a tutoria

Textos curtos para copiar e colar. Trocar `<LINK>` pelo endereço do repositório e `<DATA>` pelo prazo combinado.

---

## 1. Texto para a rota de estudos (Univirtus)

**Ambiente das aulas práticas — Sandbox Big Data**

As aulas práticas 7 a 12 foram gravadas na máquina virtual Hortonworks HDP 2.6.5, que foi descontinuada e não pode mais ser baixada. No lugar dela, use a **Sandbox Big Data**: o mesmo ambiente (Ambari, HDFS, Hive, Pig, Spark, Kafka e demais ferramentas), com os mesmos usuários e endereços que aparecem nos vídeos, só que em um container Docker que roda em computadores com 8 GB de memória.

O que fazer, na ordem:

1. Acesse <LINK> e baixe o projeto em **Code > Download ZIP**.
2. Leia o **Guia do Aluno em PDF**, que está dentro da pasta `docs`. Ele explica tudo desde a instalação, sem exigir conhecimento prévio de Docker, terminal ou SSH.
3. Instale o Docker Desktop conforme o capítulo 2 do guia (Windows, macOS ou Linux).
4. Suba o ambiente com um comando e prepare a aula desejada com outro, por exemplo `aula 10` para a aula 10.
5. Siga o roteiro da aula normalmente. Cada aula tem um arquivo que compara o vídeo com o ambiente novo e indica o que mudou.

A **Atividade Prática** pode ser feita nessa sandbox ou no notebook do Google Colab publicado no GitHub da disciplina. A escolha da plataforma é sua; as regras do roteiro valem para as duas.

Requisitos mínimos: 8 GB de memória, 40 GB livres em disco e virtualização habilitada. Dúvidas sobre instalação e erros comuns estão no capítulo 8 do guia.

---

## 2. Mensagem curta para a tutoria (alunos do piloto)

Olá! Estamos testando um ambiente novo para as aulas práticas de Big Data, que substitui a máquina virtual Hortonworks, hoje descontinuada. Em vez de uma VM de 8 GB que leva quase uma hora para iniciar, é um container Docker que sobe em cerca de um minuto e liga apenas as ferramentas de cada aula.

Você toparia testar antes de liberarmos para a turma?

O que seria necessário:

- Um computador com 8 GB de memória e 40 GB livres em disco, Windows, macOS ou Linux.
- Baixar o projeto em <LINK> e seguir o Guia do Aluno em PDF, que está na pasta `docs`. Ele parte do zero, inclusive a instalação do Docker.
- Rodar uma ou duas aulas práticas à sua escolha e a Atividade Prática.
- Responder até <DATA> contando o que funcionou, o que travou e em que ponto do guia você teve dúvida. Prints das mensagens de erro ajudam bastante.

Não é preciso saber Docker, terminal ou acesso remoto: é justamente isso que queremos testar, se o guia é claro para quem nunca usou. Qualquer problema, responda esta mensagem.
