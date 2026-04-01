# DISCLAIMER / ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ / 免责声明

---

## English


### No Warranty

THIS SOFTWARE IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, ACCURACY, COMPLETENESS, OR RELIABILITY.

### Limitation of Liability

IN NO EVENT SHALL THE AUTHORS, CONTRIBUTORS, OR COPYRIGHT HOLDERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING BUT NOT LIMITED TO PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

### Third-Party Software

This tool generates configuration for **OpenCode** and interacts with **Ollama** servers. The authors are not affiliated with, endorsed by, or responsible for OpenCode, Ollama, or any third-party software referenced herein. Users are responsible for complying with the terms of service and licenses of all third-party software they use.

### No Professional Advice

This software does not constitute professional advice of any kind, including but not limited to legal, technical, security, or operational advice. Users should consult qualified professionals before making decisions based on the output of this software.

### Security

This tool makes HTTP requests to Ollama servers specified by the user. Users are solely responsible for:

- Ensuring the security of their network connections
- Verifying the authenticity of Ollama servers
- Managing API keys and authentication credentials
- Complying with applicable security policies and regulations

### Data Handling

This tool:

- Reads model metadata from Ollama API endpoints (`/api/tags`, `/api/show`)
- Caches context length data locally (`~/.cache/opencode-generator/`)
- Does NOT collect, transmit, or store any personal data
- Does NOT communicate with any servers other than those explicitly specified by the user

### Assumption of Risk

USE OF THIS SOFTWARE IS AT THE USER'S OWN RISK. The user assumes all responsibility for any consequences arising from the use of this software, including but not limited to configuration errors, data loss, system downtime, or security incidents.

---


---

## Русский


### Отсутствие гарантий

ДАННОЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ ПРЕДОСТАВЛЯЕТСЯ «КАК ЕСТЬ» И «КАК ДОСТУПНО» БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ, ЯВНЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ, НО НЕ ОГРАНИЧИВАЯСЬ, ГАРАНТИИ ТОВАРНОГО СОСТОЯНИЯ, ПРИГОДНОСТИ ДЛЯ КОНКРЕТНОЙ ЦЕЛИ, ОТСУТСТВИЯ НАРУШЕНИЙ, ТОЧНОСТИ, ПОЛНОТЫ ИЛИ НАДЕЖНОСТИ.

### Ограничение ответственности

НИ В КОЕМ СЛУЧАЕ АВТОРЫ, УЧАСТНИКИ ИЛИ ПРАВООБЛАДАТЕЛИ НЕ НЕСУТ ОТВЕТСТВЕННОСТИ ЗА ЛЮБОЙ ПРЯМОЙ, КОСВЕННЫЙ, СЛУЧАЙНЫЙ, ОСОБЫЙ, ШТРАФНОЙ ИЛИ ПОСЛЕДОВАТЕЛЬНЫЙ УЩЕРБ (ВКЛЮЧАЯ, НЕ ОГРАНИЧИВАЯСЬ, ЗАКУПКУ ЗАМЕНАЮЩИХ ТОВАРОВ ИЛИ УСЛУГ; ПОТЕРЮ ИСПОЛЬЗОВАНИЯ, ДАННЫХ ИЛИ ПРИБЫЛИ; ИЛИ ПРЕРЫВАНИЕ БИЗНЕСА), ВОЗНИКШИЙ ПО ЛЮБОЙ ТЕОРИИ ОТВЕТСТВЕННОСТИ, НЕЗАВИСИМО ОТ ТОГО, В ДОГОВОРНОМ ПОРЯДКЕ, СТРОГОЙ ОТВЕТСТВЕННОСТИ ИЛИ ПРАВОНАРУШЕНИИ (ВКЛЮЧАЯ НЕБРЕЖНОСТЬ ИЛИ ИНАЧЕ), ВОЗНИКШИЙ В РЕЗУЛЬТАТЕ ИСПОЛЬЗОВАНИЯ ДАННОГО ПРОГРАММНОГО ОБЕСПЕЧЕНИЯ, ДАЖЕ ЕСЛИ БЫЛО УВЕДОМЛЕНО О ВОЗМОЖНОСТИ ТАКОГО УЩЕРБА.

### Стороннее программное обеспечение

Этот инструмент генерирует конфигурацию для **OpenCode** и взаимодействует с серверами **Ollama**. Авторы не связаны, не одобрены и не несут ответственности за OpenCode, Ollama или любое другое упомянутое стороннее программное обеспечение. Пользователи несут ответственность за соблюдение условий использования и лицензий всего стороннего программного обеспечения.

### Отсутствие профессиональных рекомендаций

Данное программное обеспечение не является профессиональной рекомендацией любого рода, включая юридические, технические, безопасности или операционные рекомендации. Пользователи должны консультироваться с квалифицированными специалистами перед принятием решений на основе выводов данного программного обеспечения.

### Безопасность

Этот инструмент выполняет HTTP-запросы к серверам Ollama, указанным пользователем. Пользователи несут полную ответственность за:

- Обеспечение безопасности сетевых соединений
- Проверку подлинности серверов Ollama
- Управление ключами API и учётными данными
- Соблюдение применимых политик безопасности и нормативных требований

### Обработка данных

Этот инструмент:

- Читает метаданные моделей из API-эндпоинтов Ollama (`/api/tags`, `/api/show`)
- Кэширует данные контекста локально (`~/.cache/opencode-generator/`)
- НЕ собирает, НЕ передаёт и НЕ хранит какие-либо персональные данные
- НЕ взаимодействует с какими-либо серверами, кроме явно указанных пользователем

### Принятие рисков

ИСПОЛЬЗОВАНИЕ ДАННОГО ПРОГРАММНОГО ОБЕСПЕЧЕНИЯ ОСУЩЕСТВЛЯЕТСЯ НА СОБСТВЕННЫЙ РИСК ПОЛЬЗОВАТЕЛЯ. Пользователь несёт полную ответственность за любые последствия, возникающие в результате использования данного программного обеспечения, включая, но не ограничиваясь, ошибки конфигурации, потерю данных, простои системы или инциденты безопасности.

---


---

## 中文


### 无担保

本软件按"原样"和"可用状态"提供，不提供任何形式的明示或暗示担保，包括但不限于适销性担保、特定用途适用性担保、非侵权性担保、准确性担保、完整性担保或可靠性担保。

### 责任限制

在任何情况下，作者、贡献者或版权持有人均不对因使用本软件而导致的任何直接、间接、附带、特殊、惩罚性或后果性损害（包括但不限于采购替代商品或服务；使用、数据或利润损失；或业务中断）承担责任，无论该损害是如何造成的，也无论基于何种责任理论（无论是合同责任、严格责任还是侵权责任（包括疏忽或其他）），即使已被告知发生此类损害的可能性。

### 第三方软件

本工具为 **OpenCode** 生成配置并与 **Ollama** 服务器交互。作者与 OpenCode、Ollama 或本文提及的任何第三方软件无关联、未获得其认可，也不对其负责。用户有责任遵守其使用的所有第三方软件的服务条款和许可协议。

### 非专业建议

本软件不构成任何形式的专业建议，包括但不限于法律、技术、安全或操作建议。用户在基于本软件输出做出决定之前，应咨询合格的专业人士。

### 安全性

本工具向用户指定的 Ollama 服务器发送 HTTP 请求。用户对以下事项承担全部责任：

- 确保其网络连接的安全性
- 验证 Ollama 服务器的真实性
- 管理 API 密钥和身份验证凭据
- 遵守适用的安全策略和法规

### 数据处理

本工具：

- 从 Ollama API 端点读取模型元数据（`/api/tags`、`/api/show`）
- 在本地缓存上下文长度数据（`~/.cache/opencode-generator/`）
- **不**收集、传输或存储任何个人数据
- **不**与用户未明确指定的任何服务器通信

### 风险承担

使用本软件的风险由用户自行承担。用户对因使用本软件而产生的所有后果承担全部责任，包括但不限于配置错误、数据丢失、系统停机或安全事件。


---

## Français

### CLAUSE DE NON-RESPONSABILITÉ


### Absence de garantie

CE LOGICIEL EST FOURNI « EN L'ÉTAT » ET « TEL QUE DISPONIBLE » SANS GARANTIE D'AUCUNE SORTE, EXPRESSE OU IMPLICITE, Y COMPRIS MAIS SANS S'Y LIMITER LES GARANTIES DE QUALITÉ MARCHANDE, D'ADÉQUATION À UN USAGE PARTICULIER, DE NON-INFRINGEMENT, D'EXACTITUDE, DE COMPLETITUDE OU DE FIABILITÉ.


### Limitation de responsabilité

EN AUCUN CAS LES AUTEURS, CONTRIBUTEURS OU TITULAIRES DE DROITS D'AUTEUR NE POURRONT ÊTRE TENUS RESPONSABLES DE TOUT DOMMAGE DIRECT, INDIRECT, ACCESSOIRE, SPÉCIEL, EXEMPLAIRE OU CONSÉCUTIF (Y COMPRIS MAIS SANS S'Y LIMITER L'ACHAT DE BIENS OU SERVICES DE REMPLACEMENT ; LA PERTE D'UTILISATION, DE DONNÉES OU DE BÉNÉFICES ; OU L'INTERRUPTION D'ACTIVITÉ) QUELLE QUE SOIT LA CAUSE ET QUELLE QUE SOIT LA THÉORIE DE RESPONSABILITÉ, QUE CE SOIT EN CONTRAT, RESPONSABILITÉ STRICTE OU DÉLIT (Y COMPRIS LA NÉGLIGENCE OU AUTREMENT) DÉCOULANT DE QUELQUE MANIÈRE QUE CE SOIT DE L'UTILISATION DE CE LOGICIEL, MÊME SI AVISÉ DE LA POSSIBILITÉ DE TEL DOMMAGE.


### Logiciels tiers

Cet outil génère une configuration pour **OpenCode** et interagit avec les serveurs **Ollama**. Les auteurs ne sont ni affiliés à, ni approuvés par, ni responsables de OpenCode, Ollama ou tout autre logiciel tiers référencé. Les utilisateurs sont responsables de respecter les conditions d'utilisation et les licences de tous les logiciels tiers qu'ils utilisent.


### Absence de conseil professionnel

Ce logiciel ne constitue en aucun cas un conseil professionnel de quelque nature que ce soit, y compris mais sans s'y limiter les conseils juridiques, techniques, de sécurité ou opérationnels. Les utilisateurs doivent consulter des professionnels qualifiés avant de prendre des décisions basées sur les résultats de ce logiciel.


### Sécurité

Cet outil effectue des requêtes HTTP vers les serveurs Ollama spécifiés par l'utilisateur. Les utilisateurs sont seuls responsables de :

- Assurer la sécurité de leurs connexions réseau
- Vérifier l'authenticité des serveurs Ollama
- Gérer les clés API et les identifiants d'authentification
- Respecter les politiques de sécurité et réglementations applicables


### Traitement des données

Cet outil :

- Lit les métadonnées des modèles depuis les points de terminaison API Ollama (`/api/tags`, `/api/show`)
- Met en cache les données de contexte localement (`~/.cache/opencode-generator/`)
- NE collecte, NE transmet et NE stocke aucune donnée personnelle
- NE communique avec aucun serveur autre que ceux explicitement spécifiés par l'utilisateur


### Acceptation des risques

L'UTILISATION DE CE LOGICIEL SE FAIT AUX RISQUES ET PÉRILS DE L'UTILISATEUR. L'utilisateur assume l'entière responsabilité de toute conséquence découlant de l'utilisation de ce logiciel, y compris mais sans s'y limiter les erreurs de configuration, la perte de données, les interruptions de système ou les incidents de sécurité.


---

## Deutsch

### HAFTUNGSAUSSCHLUSS


### Keine Gewährleistung

DIESE SOFTWARE WIRD 'WIE BESEHEN' UND 'WIE VERFÜGBAR' OHNE JEGLICHE GARANTIE BEREITGESTELLT, WEDER AUSDRÜCKLICH NOCH STILLSCHWEIGEND, EINSCHLIESSLICH ABER NICHT BESCHRÄNKT AUF GEWÄHRLEISTUNGEN DER MARKTGÄNGIGKEIT, EIGNUNG FÜR EINEN BESTIMMTEN ZWECK, NICHTVERLETZUNG VON RECHTEN, GENAUIGKEIT, VOLLSTÄNDIGKEIT ODER ZUVERLÄSSIGKEIT.


### Haftungsbeschränkung

UNTER KEINEN UMSTÄNDEN HAFTEN DIE AUTOREN, MITWIRKENDEN ODER URHEBERRECHTSINHABER FÜR DIREKTE, INDIREKTE, ZUFÄLLIGE, BESONDERE, MUSTERHAFT ODER FOLGESCHÄDEN (EINSCHLIESSLICH ABER NICHT BESCHRÄNKT AUF DEN ERWERB VON ERSATZGÜTERN ODER -DIENSTLEISTUNGEN; VERLUST DER NUTZUNG, DATEN ODER GEWINNE; ODER GESCHÄFTSUNTERBRECHUNG) UNABHÄNGIG VON DER URSACHE UND JEDER HAFTUNGSTHEORIE, OB VERTRAGLICH, STRIKTER HAFTUNG ODER UNERLAUBTER HANDLUNG (EINSCHLIESSLICH FAHRLÄSSIGKEIT ODER ANDERWEITIG), DIE AUS DER VERWENDUNG DIESER SOFTWARE ENTSTEHEN, AUCH WENN AUF DIE MÖGLICHKEIT SOLCHER SCHÄDEN HINGEWIESEN WURDE.


### Drittanbietersoftware

Dieses Tool generiert eine Konfiguration für **OpenCode** und interagiert mit **Ollama**-Servern. Die Autoren sind nicht mit OpenCode, Ollama oder anderer referenzierter Drittanbietersoftware verbunden, von ihr befürwortet oder für sie verantwortlich. Benutzer sind dafür verantwortlich, die Nutzungsbedingungen und Lizenzen aller von ihnen verwendeten Drittanbietersoftware einzuhalten.


### Keine professionelle Beratung

Diese Software stellt keine professionelle Beratung irgendwelcher Art dar, einschließlich aber nicht beschränkt auf rechtliche, technische, Sicherheits- oder betriebliche Beratung. Benutzer sollten qualifizierte Fachleute konsultieren, bevor sie Entscheidungen auf Grundlage der Ausgabe dieser Software treffen.


### Sicherheit

Dieses Tool sendet HTTP-Anfragen an vom Benutzer angegebene Ollama-Server. Benutzer sind allein verantwortlich für:

- Sicherstellung der Sicherheit ihrer Netzwerkverbindungen
- Überprüfung der Echtheit der Ollama-Server
- Verwaltung von API-Schlüsseln und Authentifizierungsdaten
- Einhaltung geltender Sicherheitsrichtlinien und -vorschriften


### Datenverarbeitung

Dieses Tool:

- Liest Modellmetadaten von Ollama-API-Endpunkten (`/api/tags`, `/api/show`)
- Speichert Kontextlängen lokal im Cache (`~/.cache/opencode-generator/`)
- Sammelt, übermittelt oder speichert KEINE personenbezogenen Daten
- Kommuniziert NICHT mit Servern, die nicht ausdrücklich vom Benutzer angegeben wurden


### Risikoübernahme

DIE VERWENDUNG DIESER SOFTWARE ERFOLGT AUF EIGENE GEFAHR DES BENUTZERS. Der Benutzer übernimmt die volle Verantwortung für alle Folgen, die sich aus der Verwendung dieser Software ergeben, einschließlich aber nicht beschränkt auf Konfigurationsfehler, Datenverlust, Systemausfälle oder Sicherheitsvorfälle.


---

## Español

### DESCARGO DE RESPONSABILIDAD


### Sin garantía

ESTE SOFTWARE SE PROPORCIONA "TAL CUAL" Y "SEGÚN DISPONIBILIDAD" SIN GARANTÍA DE NINGÚN TIPO, EXPRESA O IMPLÍCITA, INCLUYENDO PERO SIN LIMITARSE A GARANTÍAS DE COMERCIABILIDAD, IDONEIDAD PARA UN PROPÓSITO PARTICULAR, NO INFRACCIÓN, EXACTITUD, COMPLETITUD O FIABILIDAD.


### Limitación de responsabilidad

EN NINGÚN CASO LOS AUTORES, COLABORADORES O TITULARES DE DERECHOS DE AUTOR SERÁN RESPONSABLES POR NINGÚN DAÑO DIRECTO, INDIRECTO, INCIDENTAL, ESPECIAL, EJEMPLAR O CONSECUENTE (INCLUYENDO PERO SIN LIMITARSE A LA ADQUISICIÓN DE BIENES O SERVICIOS SUSTITUTOS; PÉRDIDA DE USO, DATOS O BENEFICIOS; O INTERRUPCIÓN DEL NEGOCIO) SIN IMPORTAR LA CAUSA Y BAJO CUALQUIER TEORÍA DE RESPONSABILIDAD, YA SEA POR CONTRATO, RESPONSABILIDAD ESTRICTA O AGRAVIO (INCLUYENDO NEGLIGENCIA O DE OTRO MODO) QUE SURJA DE CUALQUIER MANERA DEL USO DE ESTE SOFTWARE, INCLUSO SI SE ADVIRTIÓ DE LA POSIBILIDAD DE DICHO DAÑO.


### Software de terceros

Esta herramienta genera configuración para **OpenCode** e interactúa con servidores **Ollama**. Los autores no están afiliados, respaldados ni son responsables de OpenCode, Ollama o cualquier otro software de terceros mencionado. Los usuarios son responsables de cumplir con los términos de servicio y licencias de todo el software de terceros que utilicen.


### Sin asesoramiento profesional

Este software no constituye asesoramiento profesional de ningún tipo, incluyendo pero sin limitarse a asesoramiento legal, técnico, de seguridad u operativo. Los usuarios deben consultar a profesionales calificados antes de tomar decisiones basadas en la salida de este software.


### Seguridad

Esta herramienta realiza solicitudes HTTP a servidores Ollama especificados por el usuario. Los usuarios son los únicos responsables de:

- Asegurar la seguridad de sus conexiones de red
- Verificar la autenticidad de los servidores Ollama
- Gestionar claves API y credenciales de autenticación
- Cumplir con las políticas de seguridad y regulaciones aplicables


### Manejo de datos

Esta herramienta:

- Lee metadatos de modelos desde los endpoints de la API de Ollama (`/api/tags`, `/api/show`)
- Almacena en caché los datos de contexto localmente (`~/.cache/opencode-generator/`)
- NO recopila, transmite ni almacena ningún dato personal
- NO se comunica con ningún servidor que no haya sido especificado explícitamente por el usuario


### Asumción de riesgos

EL USO DE ESTE SOFTWARE ES BAJO EL PROPIO RIESGO DEL USUARIO. El usuario asume toda la responsabilidad por cualquier consecuencia derivada del uso de este software, incluyendo pero sin limitarse a errores de configuración, pérdida de datos, tiempo de inactividad del sistema o incidentes de seguridad.


---

## 日本語

### 免責事項


### 保証の否認

本ソフトウェアは「現状有姿」かつ「利用可能な状態」で提供され、商品性、特定目的適合性、非侵害性、正確性、完全性、または信頼性に関する保証を含むがこれらに限定されない、明示または黙示を問わずいかなる種類の保証も行いません。


### 責任の制限

いかなる場合においても、著者、貢献者、または著作権者は、代替商品またはサービスの調達、使用不能、データもしくは利益の損失、または業務の中断を含むがこれらに限定されない、直接的、間接的、偶発的、特別、懲罰的、または結果的損害について、契約上の責任、厳格責任、または不法行為（過失を含む）を含むいかなる責任理論に基づいても、本ソフトウェアの使用に起因するいかなる方法においても、その損害の可能性について通知されていたとしても責任を負いません。


### サードパーティソフトウェア

本ツールは**OpenCode**の設定を生成し、**Ollama**サーバーと連携します。著者はOpenCode、Ollama、または本ドキュメントで参照されるサードパーティソフトウェアとは提携しておらず、その承認を得ておらず、責任を負いません。ユーザーは、使用するすべてのサードパーティソフトウェアの利用規約とライセンスを遵守する責任があります。


### 専門的アドバイスではない

本ソフトウェアは、法的、技術的、セキュリティ、または運用上のアドバイスを含むがこれらに限定されない、いかなる種類の専門的アドバイスも構成するものではありません。ユーザーは、本ソフトウェアの出力に基づいて決定を下す前に、資格を持つ専門家に相談する必要があります。


### セキュリティ

本ツールはユーザーが指定したOllamaサーバーにHTTPリクエストを送信します。ユーザーは以下の責任を単独で負います：

- ネットワーク接続のセキュリティ確保
- Ollamaサーバーの真正性確認
- APIキーと認証資格情報の管理
- 適用されるセキュリティポリシーと規制の遵守


### データ処理

本ツールは：

- Ollama APIエンドポイント（`/api/tags`、`/api/show`）からモデルメタデータを読み取ります
- コンテキストデータをローカルにキャッシュします（`~/.cache/opencode-generator/`）
- 個人データを収集、送信、または保存しません
- ユーザーが明示的に指定したサーバー以外とは通信しません


### リスクの受容

本ソフトウェアの使用はユーザー自身の責任で行われます。ユーザーは、設定エラー、データ損失、システムダウンタイム、またはセキュリティインシデントを含むがこれらに限定されない、本ソフトウェアの使用から生じるすべての結果について全責任を負います。


---

## Português

### ISENÇÃO DE RESPONSABILIDADE


### Sem garantia

ESTE SOFTWARE É FORNECIDO "COMO ESTÁ" E "CONFORME DISPONÍVEL" SEM QUALQUER GARANTIA DE QUALQUER TIPO, EXPRESSA OU IMPLÍCITA, INCLUINDO, MAS NÃO SE LIMITANDO A GARANTIAS DE COMERCIALIZAÇÃO, ADEQUAÇÃO A UM PROPÓSITO ESPECÍFICO, NÃO VIOLAÇÃO, PRECISÃO, COMPLETUDE OU CONFIABILIDADE.


### Limitação de responsabilidade

EM NENHUM CASO OS AUTORES, CONTRIBUIDORES OU DETENTORES DE DIREITOS AUTORAIS SERÃO RESPONSÁVEIS POR QUAISQUER DANOS DIRETOS, INDIRETOS, INCIDENTAIS, ESPECIAIS, EXEMPLARES OU CONSEQUENCIAIS (INCLUINDO, MAS NÃO SE LIMITANDO À AQUISIÇÃO DE BENS OU SERVIÇOS SUBSTITUTOS; PERDA DE USO, DADOS OU LUCROS; OU INTERRUPÇÃO DE NEGÓCIOS) CAUSADOS DE QUALQUER FORMA E SOB QUALQUER TEORIA DE RESPONSABILIDADE, SEJA EM CONTRATO, RESPONSABILIDADE ESTRITA OU ATO ILÍCITO (INCLUINDO NEGLIGÊNCIA OU OUTROS) DECORRENTES DE QUALQUER FORMA DO USO DESTE SOFTWARE, MESMO SE AVISADO DA POSSIBILIDADE DE TAIS DANOS.


### Software de terceiros

Esta ferramenta gera configuração para o **OpenCode** e interage com servidores **Ollama**. Os autores não são afiliados, endossados ou responsáveis pelo OpenCode, Ollama ou qualquer outro software de terceiros referenciado. Os usuários são responsáveis por cumprir os termos de serviço e licenças de todo o software de terceiros que utilizarem.


### Sem aconselhamento profissional

Este software não constitui aconselhamento profissional de qualquer tipo, incluindo, mas não se limitando a aconselhamento jurídico, técnico, de segurança ou operacional. Os usuários devem consultar profissionais qualificados antes de tomar decisões com base na saída deste software.


### Segurança

Esta ferramenta faz solicitações HTTP para servidores Ollama especificados pelo usuário. Os usuários são os únicos responsáveis por:

- Garantir a segurança de suas conexões de rede
- Verificar a autenticidade dos servidores Ollama
- Gerenciar chaves API e credenciais de autenticação
- Cumprir as políticas de segurança e regulamentações aplicáveis


### Tratamento de dados

Esta ferramenta:

- Lê metadados dos modelos dos endpoints da API Ollama (`/api/tags`, `/api/show`)
- Armazena em cache dados de contexto localmente (`~/.cache/opencode-generator/`)
- NÃO coleta, transmite ou armazena quaisquer dados pessoais
- NÃO se comunica com quaisquer servidores além dos especificados explicitamente pelo usuário


### Assunção de riscos

O USO DESTE SOFTWARE É POR CONTA E RISCO DO USUÁRIO. O usuário assume toda a responsabilidade por quaisquer consequências decorrentes do uso deste software, incluindo, mas não se limitando a erros de configuração, perda de dados, tempo de inatividade do sistema ou incidentes de segurança.


---

## Italiano

### ESCLUSIONE DI RESPONSABILITÀ


### Nessuna garanzia

QUESTO SOFTWARE VIENE FORNITO "COSÌ COM'È" E "COME DISPONIBILE" SENZA ALCUNA GARANZIA DI ALCUN TIPO, ESPRESSA O IMPLICITA, INCLUSE, SENZA LIMITAZIONI, LE GARANZIE DI COMMERCIABILITÀ, IDONEITÀ PER UNO SCOPO PARTICOLARE, NON VIOLAZIONE, ACCURATEZZA, COMPLETEZZA O AFFIDABILITÀ.


### Limitazione di responsabilità

IN NESSUN CASO GLI AUTORI, I CONTRIBUTORI O I TITOLARI DEI DIRITTI D'AUTORE SARANNO RESPONSABILI PER QUALSIASI DANNO DIRETTO, INDIRETTO, INCIDENTALE, SPECIALE, ESEMPLARE O CONSEGUENTE (INCLUSI, SENZA LIMITAZIONI, L'ACQUISIZIONE DI BENI O SERVIZI SOSTITUTIVI; LA PERDITA DI UTILIZZO, DATI O PROFITTI; O L'INTERRUZIONE DELL'ATTIVITÀ) QUALUNQUE NE SIA LA CAUSA E QUALUNQUE SIA LA TEORIA DI RESPONSABILITÀ, SIA IN CONTRATTO, RESPONSABILITÀ OGGETTIVA O ILLECITO CIVILE (INCLUSA LA NEGLIGENZA O ALTRO) DERIVANTE IN QUALSIASI MODO DALL'USO DI QUESTO SOFTWARE, ANCHE SE AVVISATO DELLA POSSIBILITÀ DI TALI DANNI.


### Software di terze parti

Questo strumento genera la configurazione per **OpenCode** e interagisce con i server **Ollama**. Gli autori non sono affiliati, approvati o responsabili di OpenCode, Ollama o qualsiasi altro software di terze parti qui referenziato. Gli utenti sono responsabili del rispetto dei termini di servizio e delle licenze di tutto il software di terze parti che utilizzano.


### Nessuna consulenza professionale

Questo software non costituisce consulenza professionale di alcun tipo, inclusa, senza limitazione, la consulenza legale, tecnica, di sicurezza o operativa. Gli utenti dovrebbero consultare professionisti qualificati prima di prendere decisioni basate sull'output di questo software.


### Sicurezza

Questo strumento effettua richieste HTTP ai server Ollama specificati dall'utente. Gli utenti sono gli unici responsabili di:

- Garantire la sicurezza delle proprie connessioni di rete
- Verificare l'autenticità dei server Ollama
- Gestire le chiavi API e le credenziali di autenticazione
- Rispettare le politiche di sicurezza e le normative applicabili


### Gestione dei dati

Questo strumento:

- Legge i metadati dei modelli dagli endpoint API di Ollama (`/api/tags`, `/api/show`)
- Memorizza nella cache i dati del contesto localmente (`~/.cache/opencode-generator/`)
- NON raccoglie, trasmette o memorizza alcun dato personale
- NON comunica con alcun server diverso da quelli esplicitamente specificati dall'utente


### Assunzione del rischio

L'USO DI QUESTO SOFTWARE È A RISCHIO E PERICOLO DELL'UTENTE. L'utente si assume la piena responsabilità per qualsiasi conseguenza derivante dall'uso di questo software, inclusi, senza limitazione, errori di configurazione, perdita di dati, interruzioni di sistema o incidenti di sicurezza.


---

## 한국어

### 면책 조항


### 보증 없음

본 소프트웨어는 상품성, 특정 목적에의 적합성, 비침해성, 정확성, 완전성 또는 신뢰성을 포함하되 이에 국한되지 않는 어떠한 명시적 또는 묵시적 보증 없이 "있는 그대로" 및 "사용 가능한 대로" 제공됩니다.


### 책임의 제한

어떠한 경우에도 저자, 기여자 또는 저작권 보유자는 대체 상품 또는 서비스의 조달, 사용 불가, 데이터 또는 이익의 손실, 또는 사업 중단을 포함하되 이에 국한되지 않는 직접적, 간접적, 부수적, 특별, 징벌적 또는 결과적 손해에 대해 계약상의 책임, 엄격한 책임 또는 불법행위(과실 포함)를 포함한 어떠한 책임 이론에 의해서도 본 소프트웨어의 사용으로 인해 어떤 방식으로든 발생하는 손해의 가능성에 대해 통보받았더라도 책임을 지지 않습니다.


### 제3자 소프트웨어

이 도구는 **OpenCode**용 구성을 생성하고 **Ollama** 서버와 상호작용합니다. 작성자는 본 문서에서 참조된 OpenCode, Ollama 또는 제3자 소프트웨어와 제휴하거나 이를 보증하거나 이에 대한 책임을 지지 않습니다. 사용자는 사용하는 모든 제3자 소프트웨어의 서비스 약관과 라이선스를 준수할 책임이 있습니다.


### 전문가 조언이 아님

본 소프트웨어는 법률, 기술, 보안 또는 운영 조언을 포함하되 이에 국한되지 않는 어떠한 종류의 전문가 조언도 구성하지 않습니다. 사용자는 본 소프트웨어의 출력을 기반으로 결정을 내리기 전에 자격을 갖춘 전문가와 상담해야 합니다.


### 보안

이 도구는 사용자가 지정한 Ollama 서버에 HTTP 요청을 보냅니다. 사용자는 다음에 대한 전적인 책임을 집니다:

- 네트워크 연결의 보안 보장
- Ollama 서버의 진위 확인
- API 키 및 인증 자격 증명 관리
- 적용 가능한 보안 정책 및 규정 준수


### 데이터 처리

이 도구는:

- Ollama API 엔드포인트(` /api/tags`, `/api/show`)에서 모델 메타데이터를 읽습니다
- 컨텍스트 데이터를 로컬에 캐시합니다(`~/.cache/opencode-generator/`)
- 개인 데이터를 수집, 전송 또는 저장하지 않습니다
- 사용자가 명시적으로 지정한 서버 외의 서버와 통신하지 않습니다


### 위험 부담

본 소프트웨어의 사용은 사용자의 책임하에 이루어집니다. 사용자는 구성 오류, 데이터 손실, 시스템 다운타임 또는 보안 사고를 포함하되 이에 국한되지 않는 본 소프트웨어 사용으로 인한 모든 결과에 대한 전적인 책임을 집니다.


---

## العربية

### إخلاء المسؤولية


### بدون ضمان

يتم توفير هذا البرنامج "كما هو" و"حسب التوفر" دون أي ضمان من أي نوع، صريح أو ضمني، بما في ذلك على سبيل المثال لا الحصر ضمانات القابلية للتسويق والملاءمة لغرض معين وعدم الانتهاك والدقة والاكتمال أو الموثوقية.


### تحديد المسؤولية

لن يكون المؤلفون أو المساهمون أو أصحاب حقوق النشر مسؤولين بأي حال من الأحوال عن أي أضرار مباشرة أو غير مباشرة أو عرضية أو خاصة أو تبعية (بما في ذلك على سبيل المثال لا الحصر شراء سلع أو خدمات بديلة؛ أو فقدان الاستخدام أو البيانات أو الأرباح؛ أو انقطاع الأعمال) بغض النظر عن السبب وأي نظرية للمسؤولية سواء بموجب العقد أو المسؤولية الصارمة أو الضريب (بما في ذلك الإهمال أو غيره) الناشئة بأي شكل من الأشكال عن استخدام هذا البرنامج، حتى لو تم إبلاغهم بإمكانية حدوث مثل هذه الأضرار.


### برامج الطرف الثالث

تقوم هذه الأداة بإنشاء تكوين لـ **OpenCode** والتفاعل مع خوادم **Ollama**. المؤلفون غير منتسبين إلى أو معتمدين من أو مسؤولين عن OpenCode أو Ollama أو أي برامج طرف שלישי أخرى مذكورة هنا. يتحمل المستخدمون مسؤولية الالتزام بشروط الخدمة وبراءات اختراع جميع برامج الطرف الثالث التي يستخدمونها.


### بدون استشارة مهنية

لا تشكل هذه البرمجيات بأي حال من الأحوال استشارة مهنية من أي نوع، بما في ذلك على سبيل المثال لا الحصر الاستشارات القانونية أو الفنية أو الأمنية أو التشغيلية. يجب على المستخدمين استشارة مهنيين مؤهلين قبل اتخاذ قرارات بناءً على مخرجات هذه البرمجيات.


### الأمان

تقوم هذه الأداة بإجراء طلبات HTTP إلى خوادم Ollama المحددة من قبل المستخدم. يتحمل المستخدمون وحدهم مسؤولية:

- ضمان أمان اتصالاتهم بالشبكة
- التحقق من أصالة خوادم Ollama
- إدارة مفاتيح API وبيانات اعتماد المصادقة
- الامتثال لسياسات وأنظمة الأمان المعمول بها


### معالجة البيانات

تقوم هذه الأداة بـ:

- قراءة بيانات النماذج الوصفية من نقاط نهاية API لـ Ollama (`/api/tags`، `/api/show`)
- تخزين بيانات السياق مؤقتًا محليًا (`~/.cache/opencode-generator/`)
- لا تجمع أو تنقل أو تخزن أي بيانات شخصية
- لا تتواصل مع أي خوادم غير تلك المحددة صراحةً من قبل المستخدم


### تحميل المخاطر

يتم استخدام هذه البرمجيات على مسؤولية المستخدم الخاصة. يتحمل المستخدم المسؤولية الكاملة عن أي عواقب ناتجة عن استخدام هذه البرمجيات، بما في ذلك على سبيل المثال لا الحصر أخطاء التكوين أو فقدان البيانات أو توقف النظام أو حوادث الأمان.


---

## Nederlands

### AANSPRAKELIJKHEIDSVERKLARING


### Geen garantie

DEZE SOFTWARE WORDT GELEVERD "AS-IS" EN "AS-AVAILABLE" ZONDER ENIGE GARANTIE VAN WELKE AARD DAN OOK, EXPLICIET OF IMPLICIET, INCLUSIEF MAAR NIET BEPERKT TOT GARANTIES VAN VERKOOPBAARHEID, GESCHIKTHEID VOOR EEN BEPAALD DOEL, NIET-INBREUK, NAUWKEURIGHEID, VOLLEDIGHEID OF BETROUWBAARHEID.


### Beperking van aansprakelijkheid

IN GEEN GEVAL ZIJN DE AUTEURS, BIJDRAGERS OF HOUDERS VAN AUTEURSRECHTEN AANSPRAKELIJK VOOR ENIGE DIRECTE, INDIRECTE, INCIDENTELE, BIJZONDERE, VOORBEELDIGE OF GEVOLGSCHADE (INCLUSIEF MAAR NIET BEPERKT TOT DE AANSCHAF VAN VERVANGENDE GOEDEREN OF DIENSTEN; VERLIES VAN GEBRUIK, GEGEVENS OF WINST; OF ONDERBREKING VAN DE BEDRIJFSVOERING) ONDER WELKE AANSPRAKELIJKHEIDSTHEORIE DAN OOK, HETZIJ IN CONTRACT, STRIKTE AANSPRAKELIJKHEID OF ONRECHTMATIGE DAAD (INCLUSIEF NALATIGHEID OF ANDERSZINS) DIE OP ENIGE WIJZE VOORTVLOEIT UIT HET GEBRUIK VAN DEZE SOFTWARE, ZELFS ALS GEWEZEN IS OP DE MOGELIJKHEID VAN DERGELIJKE SCHADE.


### Software van derden

Dit hulprogramma genereert configuratie voor **OpenCode** en communiceert met **Ollama**-servers. De auteurs zijn niet verbonden met, goedgekeurd door of verantwoordelijk voor OpenCode, Ollama of enige andere hier genoemde software van derden. Gebruikers zijn verantwoordelijk voor het naleven van de servicevoorwaarden en licenties van alle software van derden die zij gebruiken.


### Geen professioneel advies

Deze software vormt geen professioneel advies van welke aard dan ook, inclusief maar niet beperkt tot juridisch, technisch, beveiligings- of operationeel advies. Gebruikers dienen gekwalificeerde professionals te raadplegen voordat zij beslissingen nemen op basis van de uitvoer van deze software.


### Beveiliging

Dit hulprogramma doet HTTP-verzoeken naar door de gebruiker opgegeven Ollama-servers. Gebruikers zijn als enige verantwoordelijk voor:

- Het waarborgen van de beveiliging van hun netwerkverbindingen
- Het verifiëren van de authenticiteit van Ollama-servers
- Het beheren van API-sleutels en authenticatiegegevens
- Het naleven van toepasselijke beveiligingsbeleiden en -regelgeving


### Gegevensverwerking

Dit hulprogramma:

- Leest modelmetadata van Ollama API-eindpunten (`/api/tags`, `/api/show`)
- Slaat contextgegevens lokaal op in de cache (`~/.cache/opencode-generator/`)
- Verzamelt, verzendt of slaat GEEN persoonlijke gegevens op
- Communiceert NIET met servers die niet expliciet door de gebruiker zijn opgegeven


### Risico-aanvaarding

HET GEBRUIK VAN DEZE SOFTWARE IS OP EIGEN RISICO VAN DE GEBRUIKER. De gebruiker aanvaardt de volledige verantwoordelijkheid voor alle gevolgen die voortvloeien uit het gebruik van deze software, inclusief maar niet beperkt tot configuratiefouten, gegevensverlies, systeemuitval of beveiligingsincidenten.


---

## Українська

### ВІДМОВА ВІД ВІДПОВІДАЛЬНОСТІ


### Відсутність гарантій

ЦЕ ПРОГРАМНЕ ЗАБЕЗПЕЧЕННЯ НАДАЄТЬСЯ «ЯК Є» ТА «ЯК ДОСТУПНО» БЕЗ БУДЬ-ЯКИХ ГАРАНТІЙ, ЯВНИХ ЧИ ПЕРЕДБАЧЕНИХ, ВКЛЮЧАЮЧИ, АЛЕ НЕ ОБМЕЖУЮЧИСЬ, ГАРАНТІЇ ТОВАРНОЇ ПРИДАТНОСТІ, ВІДПОВІДНОСТІ КОНКРЕТНІЙ МЕТІ, ВІДСУТНОСТІ ПОРУШЕНЬ, ТОЧНОСТІ, ПОВНОТИ АБО НАДІЙНОСТІ.


### Обмеження відповідальності

В ЖОДНОМУ РАЗІ АВТОРИ, УЧАСНИКИ АБО ПРАВОВЛАСНИКИ НЕ НЕСУТЬ ВІДПОВІДАЛЬНОСТІ ЗА БУДЬ-ЯКИЙ ПРЯМИЙ, НЕПРЯМИЙ, ВИПАДКОВИЙ, ОСОБЛИВИЙ, ШТРАФНИЙ АБО НАСЛІДКОВИЙ ЗБИТОК (ВКЛЮЧАЮЧИ, АЛЕ НЕ ОБМЕЖУЮЧИСЬ, ПРИДБАННЯ ЗАМІННИХ ТОВАРІВ АБО ПОСЛУГ; ВТРАТУ ВИКОРИСТАННЯ, ДАНИХ АБО ПРИБУТКУ; АБО ПЕРЕРВАННЯ БІЗНЕСУ) ЗА БУДЬ-ЯКОЮ ТЕОРІЄЮ ВІДПОВІДАЛЬНОСТІ, НЕЗАЛЕЖНО ВІД ТОГО, У ДОГОВІРНОМУ ПОРЯДКУ, СТРОГІЙ ВІДПОВІДАЛЬНОСТІ ЧИ ПРАВОПОРУШЕННІ (ВКЛЮЧАЮЧИ НЕДБАЛІСТЬ АБО ІНАКШЕ), ЩО ВИНИКЛО В РЕЗУЛЬТАТІ ВИКОРИСТАННЯ ЦЬОГО ПРОГРАМНОГО ЗАБЕЗПЕЧЕННЯ, НАВІТЬ ЯКЩО БУЛО ПОВІДОМЛЕНО ПРО МОЖЛИВІСТЬ ТАКОГО ЗБИТКУ.


### Стороннє програмне забезпечення

Цей інструмент генерує конфігурацію для **OpenCode** та взаємодіє з серверами **Ollama**. Автори не пов'язані, не схвалені та не несуть відповідальності за OpenCode, Ollama або будь-яке інше згадане стороннє програмне забезпечення. Користувачі несуть відповідальність за дотримання умов використання та ліцензій всього стороннього програмного забезпечення, яке вони використовують.


### Відсутність професійних рекомендацій

Це програмне забезпечення не є професійною рекомендацією будь-якого роду, включаючи юридичні, технічні, безпекові чи операційні рекомендації. Користувачі повинні консультуватися з кваліфікованими фахівцями перед прийняттям рішень на основі виводу цього програмного забезпечення.


### Безпека

Цей інструмент виконує HTTP-запити до серверів Ollama, вказаних користувачем. Користувачі несуть повну відповідальність за:

- Забезпечення безпеки мережевих з'єднань
- Перевірку автентичності серверів Ollama
- Управління ключами API та обліковими даними автентифікації
- Дотримання застосовних політик безпеки та нормативних вимог


### Обробка даних

Цей інструмент:

- Читає метадані моделей з API-ендпоінтів Ollama (`/api/tags`, `/api/show`)
- Кешує дані контексту локально (`~/.cache/opencode-generator/`)
- НЕ збирає, НЕ передає і НЕ зберігає будь-які персональні дані
- НЕ взаємодіє з будь-якими серверами, крім явно вказаних користувачем


### Прийняття ризиків

ВИКОРИСТАННЯ ЦЬОГО ПРОГРАМНОГО ЗАБЕЗПЕЧЕННЯ ЗДІЙСНЮЄТЬСЯ НА ВЛАСНИЙ РИЗИК КОРИСТУВАЧА. Користувач несе повну відповідальність за будь-які наслідки, що виникають в результаті використання цього програмного забезпечення, включаючи помилки конфігурації, втрату даний, простої системи або інциденти безпеки.


---

**Last updated / Последнее об更新 / 最后更新:** 2026-03-31  

**Version / Версия / 版本:** 1.1.0
