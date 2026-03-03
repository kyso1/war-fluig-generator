
# 📦 Gerador de WAR para Widgets Fluig

Um script em PowerShell para automatizar o empacotamento de widgets do Fluig em arquivos `.war` diretamente do código-fonte, sem a necessidade de utilizar o Eclipse.

## 💡 Por que usar este script?

O desenvolvimento tradicional de widgets para o Fluig muitas vezes amarra o desenvolvedor ao Eclipse para realizar o *export* dos pacotes. Este script resolve três problemas principais:

1. **Independência de IDE:** Permite que você programe no VS Code (ou em qualquer outro editor) e gere o pacote `.war` pelo terminal.
2. **Deploy em Massa:** Precisa atualizar várias widgets ao mesmo tempo? O script varre seu *workspace* e gera múltiplos `.war` em segundos.
3. **Plano de Contingência (Fallback):** Quando a rede ou o ambiente do Fluig estão instáveis e o upload direto da widget para o servidor falha, você pode gerar o arquivo localmente de forma rápida para realizar o deploy manual pelo painel de controle.

## ✨ Funcionalidades

- Empacotamento rápido e automatizado usando a classe de compressão nativa do .NET.
- Mapeamento inteligente de diretórios padrão do Fluig:
  - `src/main/resources/*` ➔ `WEB-INF/classes/*`
  - `src/main/webapp/*` ➔ `Raiz do WAR`
- Suporte a parâmetros via linha de comando para diretórios de origem/destino e filtro de widgets específicos.
- Interface de terminal amigável com logs coloridos e contagem de sucesso/erro.

## 🚀 Como usar

### Pré-requisitos
- Windows com PowerShell (versão 5.1 ou superior recomendada).
- Estrutura de pastas padrão de projetos Fluig.

### Configuração Inicial
Antes de rodar o script pela primeira vez, abra o arquivo `gerar-war.ps1` e edite a variável `$widgetMap`. Você precisa mapear o nome da pasta da sua widget para o nome interno dela:

```powershell
# Exemplo de mapeamento no script
$widgetMap = [ordered]@{
    "WIDGET_minha_widget" = "w_minha_widget"
    "WIDGET_outra_widget" = "w_outra_widget"
}

```

### Comandos de Execução

Você pode executar o script de várias maneiras dependendo da sua necessidade:

**1. Gerar todas as widgets mapeadas (usando diretórios padrão):**

```powershell
.\gerar-war.ps1
```

**2. Gerar apenas widgets específicas:**

```powershell
.\gerar-war.ps1 -Widgets "WIDGET_nome", "WIDGET_nome2"
```

**3. Informar caminhos customizados de origem e destino:**

```powershell
.\gerar-war.ps1 -WidgetsDir "C:\meu-workspace\widgets" -OutputDir "C:\meus-wars"
```

## 📂 Estrutura Esperada

O script espera que o seu diretório de widgets (`WidgetsDir`) siga a estrutura padrão de projetos do Fluig gerados via plugin:

```text
[WidgetsDir]\
 └── WIDGET_nome\
      └── wcm\
           └── widget\
                └── w_nome\
                     ├── src\main\resources\  (Arquivos de propriedades, etc.)
                     └── src\main\webapp\     (JSP, CSS, JS, etc.)

```

## 📝 Licença

Distribuído sob a licença MIT. Sinta-se à vontade para fazer um *fork* e adaptar para a realidade dos seus projetos!

Você gostaria que eu inclua um bloco ensinando como contornar as políticas de execução do Windows caso o PowerShell bloqueie a execução do script (`Set-ExecutionPolicy`)?

`
