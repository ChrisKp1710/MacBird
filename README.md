# MacBird Browser

**MacBird** è un browser web open source per macOS, scritto in C++ e basato su WebKit, con un design moderno e un’esperienza utente ottimizzata per l’estetica di macOS. Ispirato a progetti come Ladybird, MacBird combina semplicità, funzionalità e un’interfaccia elegante per offrire un browser usabile e personalizzabile.

## Obiettivo

Creare un browser open source che chiunque possa usare liberamente, con un focus su:

* **Estetica macOS**: Interfaccia fluida, moderna, con titlebar trasparente, supporto dark mode, e toolbar centrata.
* **Funzionalità pratiche**: Multi-tab, devtools integrati, navigazione fluida, e identità browser personalizzata.
* **Open source**: Codice pubblico su GitHub per incoraggiare contributi e personalizzazioni.
* **Evoluzione futura**: Mantenere WebKit per un prototipo rapido, con l’obiettivo a lungo termine di sviluppare un renderer proprietario per un’esperienza più “da zero”.

MacBird non è solo un progetto educativo, ma un browser che punta a essere usato nella vita reale, con un design che si distingue e si integra perfettamente con macOS.

## Stato Attuale

🚧** ****In sviluppo - Fase 1**
MacBird è un prototipo funzionante con le seguenti funzionalità:

* Interfaccia moderna con titlebar trasparente e dark mode.
* Sistema multi-tab con isolamento dei processi (basato su** **`WKWebView`).
* Devtools base con console, elementi, e rete.
* Identità browser personalizzata (User-Agent, headers) tramite** **`BrowserInfo`.
* Menu bar con azioni standard (reload, zoom, full screen, view source).

**Prossimi passi**:** **

* Aggiungere una barra di ricerca funzionante.
* Implementare history e bookmarks.
* Migliorare i devtools con funzionalità avanzate.
* Pianificare un renderer proprietario per future versioni.

## Requisiti

* **Sistema operativo**: macOS 13.0 (Ventura) o successivo
* **Strumenti**:
  * Xcode 14 o successivo
  * CMake 3.10 o successivo
* **Librerie**: Cocoa e WebKit (incluse in macOS)

## Installazione e Build

1. Clona il repository:
   ```bash
   git clone https://github.com/ChrisKp1710/MacBird.git
   cd MacBird
   ```
2. Genera i file di build con CMake:
   ```bash
   cmake .
   ```
3. Compila il progetto:
   ```bash
   make
   ```
4. Esegui MacBird:
   ```bash
   ./MacBird
   ```

## Struttura del Progetto

```
MacBird/
├── CMakeLists.txt          # Configurazione build
├── Source/
│   ├── Core/
│   │   └── Browser/
│   │       ├── BrowserInfo.h    # Identità browser (User-Agent, versione)
│   │       └── BrowserInfo.mm
│   ├── Platform/
│   │   └── macOS/
│   │       ├── AppDelegate.h    # Gestione lifecycle app
│   │       ├── AppDelegate.mm
│   │       ├── BrowserWindow.h  # Finestra principale e UI
│   │       ├── BrowserWindow.mm
│   │       ├── MenuManager.h    # Menu bar
│   │       └── MenuManager.mm
│   ├── UI/
│   │   └── TabSystem/
│   │       ├── Tab.h           # Singola tab
│   │       ├── Tab.mm
│   │       ├── TabManager.h    # Gestione multi-tab
│   │       └── TabManager.mm
│   ├── DevTools/
│   │   ├── Common/
│   │   │   └── DevToolsStyles.mm  # Stili devtools
│   │   ├── Console/
│   │   │   └── ConsoleTab.mm     # Console devtools
│   │   ├── Elements/
│   │   │   └── ElementsTab.mm    # Inspector elementi
│   │   ├── Network/
│   │   │   └── NetworkTab.mm     # Monitor rete
│   │   └── DevToolsManager.mm    # Gestione devtools
│   └── main.mm                  # Entry point
├── Resources/                   # Risorse (es. icone)
├── Tests/                       # Test unitari (in sviluppo)
├── Documentation/               # Documentazione (in sviluppo)
└── README.md
```

## Motivazione per WebKit

MacBird usa WebKit per il rendering e il networking per garantire un prototipo rapido, stabile e compatibile con i siti moderni. Questo permette di concentrarsi su un design innovativo e funzionalità utente (es. multi-tab, devtools) senza dover costruire un renderer da zero. In futuro, pianifichiamo di sviluppare un parser HTML/CSS proprietario in** **`Source/Core/DOM` per un’esperienza più personalizzata, mantenendo MacBird usabile durante la transizione.

## Contribuire

MacBird è open source e accoglie contributi! Per iniziare:

1. Forka il repository.
2. Crea un branch per le tue modifiche (`git checkout -b mia-feature`).
3. Committa le modifiche (`git commit -m "Aggiunta mia feature"`).
4. Pusha il branch (`git push origin mia-feature`).
5. Apri una Pull Request.

Cerchiamo aiuto per:

* Aggiungere search bar, history, e bookmarks.
* Migliorare i devtools.
* Scrivere test unitari in** **`Tests/`.
* Progettare un renderer proprietario.

## Licenza

MacBird è rilasciato sotto la licenza MIT (in arrivo).

## Contatti

Per domande o suggerimenti, apri una issue su GitHub o contatta** **[ChrisKp1710](https://github.com/ChrisKp1710).

---

**MacBird**: Un browser open source per macOS, semplice, elegante e fatto per gli utenti.
