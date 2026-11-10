# Perguntas frequentes

Respostas curtas para as dúvidas mais comuns, na ordem em que elas costumam aparecer: primeiro as da instalação no Windows, depois as do uso no dia a dia. Este é o mesmo conteúdo do capítulo 9 do [Guia do Aluno em PDF](Guia-do-Aluno.pdf).

- [1. Políticas e permissões do Windows](#1-políticas-e-permissões-do-windows)
- [2. Docker e a imagem](#2-docker-e-a-imagem)
- [3. Subir a sandbox, portas e acessos](#3-subir-a-sandbox-portas-e-acessos)
- [4. Durante as aulas](#4-durante-as-aulas)
- [5. Memória, desempenho e disco](#5-memória-desempenho-e-disco)
- [6. Atividade Prática](#6-atividade-prática)

---

## 1. Políticas e permissões do Windows

Este é o grupo que gera mais dúvida, e nada aqui é defeito da sandbox: o Windows bloqueia, por padrão, arquivos baixados da internet e scripts sem assinatura digital. São proteções do sistema que você libera uma única vez.

### Atalho: a sequência que destrava o `lab.ps1` em qualquer computador

Se você só quer que funcione, sem entender cada bloqueio, execute estes dois comandos no PowerShell, dentro da pasta do projeto:

```powershell
Unblock-File -Path .\lab.ps1
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\lab.ps1 up
```

O primeiro tira a marca de "arquivo vindo da internet". O segundo executa o script ignorando a política de execução **apenas naquela janela**, sem mudar nenhuma configuração do Windows. Depois é só trocar o `up` pelo comando que você quiser: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\lab.ps1 aula 10`. As perguntas a seguir explicam cada bloqueio em separado, para quem quiser entender o que está acontecendo.

### Aparece "não é possível carregar o arquivo … porque a execução de scripts foi desabilitada neste sistema"

O Windows vem configurado para não executar nenhum script do PowerShell. Execute uma única vez o comando abaixo na mesma janela, responda `S` e repita o `.\lab.ps1 up`. Ele vale somente para o seu usuário e não pede senha de administrador.

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Liberei a política, mas agora aparece "O arquivo lab.ps1 não está assinado digitalmente"

O arquivo veio da internet e o Windows o marcou como "de outro computador". A política `RemoteSigned` recusa justamente scripts baixados que não tenham assinatura digital — é o caso dos nossos.

O melhor caminho é desbloquear o **ZIP antes de extrair**: botão direito no arquivo baixado, **Propriedades**, e na parte de baixo da aba **Geral** marque **Desbloquear** e clique em OK. Se já extraiu, abra o PowerShell na pasta do projeto e execute:

```powershell
Get-ChildItem -Recurse | Unblock-File
```

Esse comando só remove a marca de origem dos arquivos que você acabou de baixar. Ele não altera o conteúdo deles nem desliga nenhuma proteção do Windows.

Se mesmo depois de desbloquear o arquivo o PowerShell continuar recusando, a política do seu computador está fixada pela instituição — veja a pergunta seguinte.

### O `Set-ExecutionPolicy` responde que "a configuração é substituída por uma política definida em um escopo mais específico"

O computador é gerenciado por uma empresa, escola ou órgão público, e a política está fixada por Diretiva de Grupo. Confirme com `Get-ExecutionPolicy -List`: se a linha `MachinePolicy` ou `UserPolicy` mostrar algo diferente de `Undefined`, você não consegue alterar isso sem o setor de TI. Há duas saídas que não dependem de ninguém:

- Não usar o `lab.ps1` e chamar o Docker diretamente — veja a pergunta seguinte.
- Executar o script apenas nesta janela, sem mudar nada no sistema: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\lab.ps1 up`.

### Como uso a sandbox sem o `lab.ps1` ou o `lab.sh`?

Os dois scripts só economizam digitação: tudo que eles fazem são comandos do `docker compose`. Na pasta do projeto, estes são os equivalentes, iguais no Windows, no macOS e no Linux:

```bash
docker compose up -d                          # subir a sandbox
docker compose exec sandbox lab wait-ambari   # esperar o Ambari responder
docker compose exec sandbox lab urls          # ver os endereços de acesso
docker compose exec sandbox lab aula 10       # preparar a aula 10
docker compose exec sandbox lab status        # ver o que está de pé
docker compose --profile nosql down           # desligar

docker compose exec -u maria_dev -w /home/maria_dev sandbox bash -l   # terminal
```

### Apareceu "O Windows protegeu o seu PC" ao abrir o instalador do Docker Desktop

É o SmartScreen avisando que o arquivo ainda é pouco comum na sua máquina. Desde que você tenha baixado do site oficial ([docs.docker.com](https://docs.docker.com/desktop/setup/install/windows-install/)), clique em **Mais informações** e depois em **Executar assim mesmo**. Se esse botão não aparecer, o bloqueio vem de uma política da instituição e só o setor de TI pode liberar.

### O Docker Desktop diz "You are not allowed to use Docker. You must be in the 'docker-users' group"

No Windows, o Docker Desktop só permite o uso a quem está no grupo local `docker-users`. O instalador inclui automaticamente a conta que instalou; se a instalação foi feita por outra pessoa (um técnico, por exemplo), um administrador precisa executar o comando abaixo em um PowerShell aberto como administrador. Depois disso, saia e entre novamente na sua sessão do Windows.

```powershell
net localgroup docker-users "NOME-DO-PC\seu_usuario" /add
```

### `wsl --install` responde "Acesso negado" ou pede privilégios de administrador

Esse comando exige um PowerShell aberto com **Executar como administrador**. Em notebooks corporativos ou de laboratório sem direitos de administrador não há como instalar o WSL2 por conta própria; fale com o setor de TI. Enquanto isso, a Atividade Prática pode ser feita no [Google Colab](https://colab.research.google.com/github/N-CPUninter/Big_Data/blob/main/trabalho_big_data.ipynb), que roda no navegador e não instala nada no computador.

### O Gerenciador de Tarefas mostra "Virtualização: Desabilitado" e eu não consigo entrar na BIOS

Sem virtualização o Docker Desktop não funciona, e essa opção fica na BIOS/UEFI do equipamento — em máquinas gerenciadas, normalmente protegida por senha. Antes de desistir, verifique se não é conflito de software: VPNs corporativas, alguns antivírus e máquinas virtuais abertas (VirtualBox, VMware) podem estar ocupando o recurso de virtualização. Feche-os e reinicie o computador. Se a mensagem continuar, é caso para o setor de TI.

### O antivírus reclamou, ou tudo ficou lentíssimo depois de instalar

O **Acesso controlado a pastas** do Windows Defender e alguns antivírus de terceiros bloqueiam a gravação do Docker em pastas pessoais. Mantenha o projeto em `C:\bigdata-lab`, fora de **Documentos**, **Área de Trabalho** e de qualquer pasta sincronizada pelo OneDrive. Se o antivírus continuar acusando, adicione essa pasta à lista de exclusões dele.

### O Windows pediu permissão de firewall quando subi a sandbox. Preciso aceitar?

Sim. Marque a caixa de **redes privadas** e clique em **Permitir acesso**: é essa permissão que faz os endereços `localhost:8080`, `localhost:4200` e os demais chegarem até a sandbox. Se você negou sem querer, vá em **Painel de Controle > Sistema e Segurança > Firewall do Windows Defender > Permitir um aplicativo ou recurso** e libere o Docker Desktop.

### Ao subir aparece "An attempt was made to access a socket in a way forbidden by its access permissions"

O Windows reserva faixas dinâmicas de portas TCP para uso interno do Hyper-V, e uma porta da sandbox pode cair dentro de uma delas. Veja as faixas reservadas com:

```powershell
netsh interface ipv4 show excludedportrange protocol=tcp
```

Se alguma porta da sandbox (8080, 8888, 4200, 2222, 8088, 9870, 10000 ou 11000) estiver em uma faixa, abra um PowerShell como administrador e reinicie o serviço de rede do Hyper-V, o que faz o Windows recalcular as reservas. Depois suba a sandbox de novo:

```powershell
net stop winnat
net start winnat
```

Se a porta continuar ocupada, troque o número do lado esquerdo na linha correspondente do `docker-compose.yml` (por exemplo `"8081:8080"` em vez de `"8080:8080"`) e use o novo número no navegador.

### Posso deixar a pasta do projeto no OneDrive ou na Área de Trabalho?

Não é recomendado. O OneDrive pode guardar os arquivos apenas como atalhos na nuvem ("Arquivos sob demanda"), e então eles aparecem vazios dentro da sandbox. Além disso, caminhos com espaços e acentos ("Área de Trabalho", "Documentos") atrapalham o Docker no Windows. Use `C:\bigdata-lab`.

### Na extração do ZIP apareceu erro de "caminho muito longo"

O Windows limita caminhos a 260 caracteres por padrão. Extraia para uma pasta curta, como `C:\bigdata-lab`, e não para dentro de algo como `Downloads\bigdata-lab-docker-main\bigdata-lab-docker-main\`.

---

## 2. Docker e a imagem

### Preciso criar uma conta no Docker?

Não. Feche a tela de login com **Skip** ou **Continue without signing in**. A imagem da sandbox é pública e baixa sem login.

### O download é muito grande e a conexão caiu no meio

A imagem tem cerca de 22 GB e é baixada **uma única vez**. Se a conexão cair, repita o comando: o Docker retoma de onde parou, camada por camada. Prefira rede por cabo ou um Wi-Fi estável, e evite redes com limite de dados.

### "no space left on device" ou o Docker reclama de disco

Veja quanto o Docker está ocupando com `docker system df` e limpe o que não está em uso com `docker system prune`. **Não** use `docker system prune -a --volumes`: isso apagaria a imagem da sandbox e os seus dados. No Windows o disco do Docker fica dentro do WSL2, normalmente na unidade `C:`; se o `C:` estiver cheio, é preciso liberar espaço nele.

### Como sei se estou com a versão mais nova da sandbox?

Na pasta do projeto, `docker compose pull` baixa a versão publicada mais recente; depois `.\lab.ps1 up` (ou `./lab.sh up`) sobe com ela. Seus dados ficam em volumes do Docker e sobrevivem à atualização.

### Funciona no Windows 10 ou 11 Home?

Sim. Com o WSL2 não é preciso ter o Windows Pro.

### Depois de instalar, preciso de internet para estudar?

Não, fora do primeiro download. Só precisam de rede as aulas que buscam dados externos e, naturalmente, o Google Colab.

---

## 3. Subir a sandbox, portas e acessos

### `localhost:8080` não abre logo depois do `up`

Na primeira subida o Ambari leva de dois a quatro minutos para responder. O comando `up` espera por ele e só então mostra os endereços de acesso; se você abriu o navegador antes disso, atualize a página. Passados cinco minutos, veja `.\lab.ps1 logs` (ou `./lab.sh logs`).

### Quais são os usuários e senhas?

No Ambari, `admin` / `admin`. Dentro da sandbox, `maria_dev` / `maria_dev`, `raj_ops` / `raj_ops` e `root` / `hadoop`. São os mesmos da máquina virtual antiga.

### Como entro por SSH? Preciso instalar o PuTTY?

Não precisa instalar nada: o Windows 10 e 11, o macOS e o Linux já trazem o comando `ssh`. No PowerShell ou no Terminal, execute `ssh maria_dev@localhost -p 2222` e informe a senha `maria_dev`. Na primeira vez ele pergunta se você confia nessa máquina; responda `yes`. Quem preferir pode usar o terminal no navegador, em [localhost:4200](http://localhost:4200), que não exige nada instalado e já entra como `maria_dev`.

### O SSH passou a dizer "REMOTE HOST IDENTIFICATION HAS CHANGED"

Isso acontece depois de um `reset`: a sandbox foi recriada e tem uma identidade nova. Apague a identidade antiga e tente outra vez:

```bash
ssh-keygen -R "[localhost]:2222"
```

### A porta 8080 já é usada por outro programa meu

Troque o número do lado esquerdo no `docker-compose.yml` (`"8081:8080"`), suba a sandbox de novo e use `localhost:8081` no navegador. O mesmo vale para qualquer outra porta.

---

## 4. Durante as aulas

### O comando da aula falha com "Connection refused", fica preso ou diz que o HDFS está em safe mode

Os serviços ainda não estão de pé. O `up` liga apenas o Ambari; é o `aula <perfil>` que liga os serviços daquela aula, e ele termina escrevendo `PRONTO em Xm00s`. Espere essa mensagem antes de digitar qualquer comando da aula, abrir o SSH ou as interfaces web. Para conferir a qualquer momento, use `lab status` dentro da sandbox ou `.\lab.ps1 status` no seu computador.

### Esqueci qual perfil está ligado

`.\lab.ps1 status` (ou `./lab.sh status`) lista os serviços em pé. No Ambari, a mesma informação aparece na lista de serviços da esquerda: tudo verde significa pronto.

### Posso trocar de aula sem desligar tudo?

Sim. Execute o `aula` com o novo perfil: ele desliga o que não é necessário e liga o que falta. Por exemplo `aula 7`, `aula 8a`, `aula 10`, `aula trabalho`, ou `aula none` para desligar tudo e deixar só o Ambari.

### Meus arquivos somem quando eu desligo a sandbox?

Não. O `down` apenas para os containers: o HDFS, os bancos e a pasta da `maria_dev` ficam guardados em volumes do Docker. O único comando que apaga tudo é o `reset`, e ele pede confirmação digitando `SIM`.

### Como levo um arquivo do meu computador para dentro da sandbox?

Coloque-o na pasta `data` ou `aulas` do projeto: elas aparecem dentro da sandbox como `/data` e `/aulas`. Para colocar o arquivo no HDFS, use o Files View do Ambari ou `hdfs dfs -put`.

### No vídeo o NameNode abre em `localhost:50070` e aqui não funciona

Dentro da sandbox a porta continua sendo a 50070, mas no seu navegador o endereço é [localhost:9870](http://localhost:9870), porque o Windows reserva a faixa 50000–50959 para uso interno.

### Um serviço ficou vermelho no Ambari

Vá em **Ambari > Background Operations**, clique na operação e leia o `stderr`. As duas causas mais comuns são falta de memória e disco cheio do Docker. Repetir o `aula <perfil>` resolve boa parte dos casos.

---

## 5. Memória, desempenho e disco

### O Windows inteiro travou enquanto a sandbox rodava

Falta o limite de memória do WSL2. Sem o arquivo `.wslconfig` o WSL2 pode tomar metade da RAM do computador. Crie o arquivo conforme o [guia de instalação](INSTALACAO.md), execute `wsl --shutdown` e abra o Docker Desktop novamente.

### O processo `vmmem` (ou `Docker Desktop`) aparece usando vários GB

É esperado: essa é a memória da sandbox, e o teto é o que você definiu no `.wslconfig`. Em máquina de 8 GB use `memory=6GB`; com 16 GB ou mais, `memory=10GB`.

### Tenho só 8 GB de RAM. Dá conta?

Sim, usando um perfil por vez e o perfil de memória `8g` (`lab mem 8g`). O que não cabe é ligar vários serviços pesados ao mesmo tempo, como Hive, HBase, Kafka e Storm juntos. A tabela de consumo por aula está em [MEMORIA.md](MEMORIA.md).

### Posso fechar o Docker Desktop e continuar usando a sandbox?

Não: ele é o motor que roda a sandbox. Para liberar o computador sem perder nada, execute `.\lab.ps1 down` (ou `./lab.sh down`) e só depois feche o Docker Desktop.

---

## 6. Atividade Prática

### Colab ou sandbox? A escolha muda a correção?

Não muda. O roteiro e os critérios são os mesmos nas duas plataformas; escolha a mais conveniente para você. O Colab não exige instalação e é a opção mais leve, inclusive em Mac com chip Apple.

### A sessão do Colab caiu e perdi os arquivos

O Colab desliga a máquina após algum tempo sem uso e apaga os arquivos baixados, mas **o código que você escreveu fica salvo no notebook**. Execute de novo as células do início (download, descompactação e `pip`) e siga de onde parou.

---

Não achou o seu caso? Veja a lista de erros com as mensagens exatas em [TROUBLESHOOTING.md](TROUBLESHOOTING.md).
