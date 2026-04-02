# مولد تكوين OpenCode لـ Ollama

يُنشئ تكوين `opencode.json` من خوادم Ollama المحلية والبعيدة.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

English | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.4.3** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

## الميزات

- **دعم متعدد المزودين**: Ollama، LM Studio، vLLM، llama.cpp، LocalAI، text-generation-webui، Jan.ai، GPT4All
- يكتشف المزود تلقائياً حسب المنفذ، أو حدده بـ `-p`
- يكتشف جميع النماذج تلقائياً عبر واجهة API للمزود
- يستبعد نماذج التضمين (nomic-bert، حقل type الخاص بـ LM Studio، إلخ)
- يفلتر النماذج حسب دعم استدعاء الأدوات/الدوال (`--tools-only`)
- يجلب أطوال السياق الدقيقة (Ollama `/api/show`، llama.cpp `/props`، LM Studio بيانات وصفية غنية)
- يدعم خوادم متعددة من مزودين مختلفين في وقت واحد
- اختيار تفاعلي للنماذج (مع خيار "جميع النماذج")
- تضمين/استبعاد النماذج بأنماط glob
- يكتشف `small_model` تلقائياً (أصغر نموذج غير embed لتوليد العناوين)
- وضع المعاينة بدون كتابة (dry-run)
- يحترم متغير البيئة `OLLAMA_HOST`

## المتطلبات

| المكوّن | سكريبت Bash | سكريبت PowerShell |
|---------|:-----------:|:-----------------:|
| curl    | مطلوب       | غير مطلوب         |
| Python 3 | مطلوب      | غير مطلوب         |
| PowerShell 5.1+ | غير متاح | مطلوب         |

## البداية السريعة

```bash
# Bash (Linux/macOS/WSL/Git Bash)
./generate_opencode_config.sh

# PowerShell (Windows)
.\Generate-OpenCodeConfig.ps1
```

## الاستخدام

### Bash

```bash
# Ollama المحلي فقط (يستخدم $OLLAMA_HOST أو http://localhost:11434)
./generate_opencode_config.sh

# مع خادم بعيد واحد
./generate_opencode_config.sh -r http://192.168.1.100:11434

# مع خوادم بعيدة متعددة
./generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

# اختيار تفاعلي للنماذج
./generate_opencode_config.sh -i

# نماذج qwen فقط
./generate_opencode_config.sh --include "qwen*"

# استبعاد codestral
./generate_opencode_config.sh --exclude "codestral*"

# تضمين نماذج التضمين (embedding)
./generate_opencode_config.sh --with-embed

# النماذج التي تدعم استدعاء الأدوات/الدوال فقط
./generate_opencode_config.sh --tools-only

# معاينة بدون كتابة الملف
./generate_opencode_config.sh -n

# إضافة num_ctx إلى خيارات المزود (لاستدعاء الأدوات)
./generate_opencode_config.sh --num-ctx 32768

# تعيين النموذج الافتراضي صراحةً
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# دمج في التكوين الموجود (تحديث النماذج، الاحتفاظ بالإعدادات الأخرى)
./generate_opencode_config.sh --merge

# تخطي استدعاءات /api/show (أسرع، يستخدم حدود سياق ثابتة)
./generate_opencode_config.sh --no-context-lookup

# تعطيل ذاكرة التخزين المؤقت للبحث عن السياق
./generate_opencode_config.sh --no-cache

# الكتابة إلى التكوين العام
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json
```

### PowerShell

```powershell
# Ollama المحلي فقط
.\Generate-OpenCodeConfig.ps1

# مع خوادم بعيدة
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"

# اختيار تفاعلي
.\Generate-OpenCodeConfig.ps1 -Interactive

# نماذج qwen فقط
.\Generate-OpenCodeConfig.ps1 -Include "qwen*"

# معاينة بدون كتابة
.\Generate-OpenCodeConfig.ps1 -DryRun

# مع num_ctx
.\Generate-OpenCodeConfig.ps1 -NumCtx 32768

# الكتابة إلى التكوين العام
.\Generate-OpenCodeConfig.ps1 -OutputFile "$env:USERPROFILE\.config\opencode\opencode.json"
```

## مرجع CLI

### Bash

| العلم | الوصف | الافتراضي |
|-------|-------|-----------|
| `-l, --local URL` | عنوان URL للخادم المحلي | `$OLLAMA_HOST` أو `http://localhost:11434` |
| `-r, --remote URL` | عنوان URL للخادم البعيد (قابل للتكرار) | لا يوجد |
| `-p, --provider الاسم` | المزود: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | اكتشاف تلقائي |
| `-o, --output الملف` | مسار ملف الإخراج (`-` لـ stdout) | `opencode.json` |
| `-n, --dry-run` | طباعة على stdout، بدون كتابة | معطل |
| `-i, --interactive` | اختيار تفاعلي للنماذج | معطل |
| `--include النمط` | تضمين النماذج المطابقة لـ glob (قابل للتكرار) | الكل |
| `--exclude النمط` | استبعاد النماذج المطابقة لـ glob (قابل للتكرار) | لا يوجد |
| `--with-embed` | تضمين نماذج التضمين | مستبعد |
| `--tools-only` | النماذج التي تدعم استدعاء الأدوات/الدوال فقط | معطل |
| `--no-context-lookup` | تخطي `/api/show`، استخدام الحدود الثابتة | معطل |
| `--num-ctx N` | `num_ctx` لخيارات المزود، 0 للحذف | `0` |
| `--merge` | دمج في التكوين الموجود (تحديث النماذج فقط) | معطل |
| `--default-model ID` | تعيين النموذج الافتراضي صراحةً | تلقائي |
| `--small-model ID` | تعيين small_model صراحةً (لتوليد العناوين) | تلقائي |
| `--no-cache` | تعطيل ذاكرة التخزين المؤقت للبحث عن السياق | معطل |
| `-v, --version` | عرض الإصدار | |
| `-h, --help` | عرض المساعدة | |

### PowerShell

| المعامل | الوصف | الافتراضي |
|---------|-------|-----------|
| `-LocalOllamaUrl` | عنوان URL لـ Ollama المحلي | `$OLLAMA_HOST` أو `http://localhost:11434` |
| `-RemoteOllamaUrl` | عناوين URL البعيدة (مصفوفة) | لا يوجد |
| `-OutputFile` | مسار ملف الإخراج | `opencode.json` |
| `-DryRun` | طباعة على stdout، بدون كتابة | معطل |
| `-Interactive` | اختيار تفاعلي للنماذج | معطل |
| `-Include` | أنماط التضمين (wildcard، مصفوفة) | الكل |
| `-Exclude` | أنماط الاستبعاد (wildcard، مصفوفة) | لا يوجد |
| `-WithEmbed` | تضمين نماذج التضمين | مستبعد |
| `-ToolsOnly` | النماذج التي تدعم استدعاء الأدوات/الدوال فقط | معطل |
| `-NoContextLookup` | تخطي `/api/show`، استخدام الحدود الثابتة | معطل |
| `-NumCtx` | `num_ctx` لخيارات المزود، 0 للحذف | `0` |
| `-Merge` | دمج في التكوين الموجود (تحديث النماذج فقط) | معطل |
| `-DefaultModel` | تعيين النموذج الافتراضي صراحةً | تلقائي |
| `-SmallModel` | تعيين small_model صراحةً (لتوليد العناوين) | تلقائي |
| `-NoCache` | تعطيل ذاكرة التخزين المؤقت للبحث عن السياق | معطل |
| `-Version` | عرض الإصدار | |
| `-Help` | عرض المساعدة | |

## كيف يعمل

1. **جلب النماذج** من كل خادم Ollama عبر `GET /api/tags`
2. **تصفية** نماذج التضمين حسب حقل `families` (`nomic-bert`، `bert`، إلخ)
3. **تصفية** بأنماط include/exclude (مطابقة glob)
4. **جلب أطوال السياق** لكل نموذج عبر `POST /api/show` (متوازي، مع ذاكرة تخزين مؤقت)
5. **إزالة التكرار** للنماذج الموجودة على خوادم متعددة (يحتفظ بنسخة الخادم الأول)
6. **اختيار تفاعلي** (إذا `-i`): قائمة مرقمة مع خيار `[0] جميع النماذج`
7. **دمج** (إذا `--merge`): الحفاظ على إعدادات التكوين الموجودة والمزودين الآخرين
8. **اكتشاف `small_model` تلقائياً**: أصغر نموذج غير embed حسب عدد المعاملات
9. **إنشاء** `opencode.json` مع Ollama كمزود

## بنية التكوين المُولَّد

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "llama3.2:latest": {
          "name": "Llama 3.6B Q4_K_M (local)",
          "limit": {
            "context": 131072,
            "output": 16384
          }
        }
      }
    }
  },
  "model": "ollama/llama3.2:latest",
  "small_model": "ollama/qwen2.5-coder:3b"
}
```

### الحقول

| الحقل | الوصف |
|-------|-------|
| `provider.ollama.options.baseURL` | نقطة نهاية Ollama المتوافقة مع OpenAI |
| `provider.ollama.models.*.limit.context` | أقصى نافذة سياق للنموذج |
| `provider.ollama.models.*.limit.output` | أقصى رموز إخراج (محدودة بـ 16K) |
| `model` | النموذج الافتراضي (الأول المتاح) |
| `small_model` | أصغر نموذج للمهام الخفيفة (توليد العناوين) |

## اكتشاف سياق النموذج

يتم تحديد أطوال السياق بترتيب الأولوية التالي:

1. **بحث API** — `POST /api/show` يُرجع `model_info.*.context_length` (قيمة دقيقة)
2. **احتياطي ثابت** — مُقدَّر حسب عائلة النموذج:

| العائلة | السياق الافتراضي |
|---------|:----------------:|
| qwen, qwen2 | 32,768 |
| llama | 8,192 |
| mistral, mixtral | 32,768 |
| deepseek | 65,536 |
| command, command-r | 131,072 |
| yi | 200,000 |
| gemma | 8,192 |
| phi | 4,096 |
| codestral | 32,768 |
| granite | 8,192 |
| أخرى | 8,192 |

استخدم `--no-context-lookup` لتخطي استدعاءات API واستخدام القيم الثابتة فقط (أسرع).

## نماذج التضمين (Embedding)

نماذج التضمين **مستبعدة افتراضياً** لأنها لا تدعم استدعاء الدردشة/الأدوات. يعتمد الاكتشاف على:

- عائلات النماذج التي تحتوي على `nomic-bert`، `bert`، `bert-moe`، `embed`، `embedding`
- أسماء النماذج التي تحتوي على هذه الكلمات المفتاحية

استخدم `--with-embed` / `-WithEmbed` لتضمينها.

## فلتر استدعاء الأدوات/الدوال

استخدم `--tools-only` / `-ToolsOnly` لتضمين النماذج التي تدعم استدعاء الأدوات/الدوال فقط:

```bash
./generate_opencode_config.sh --tools-only
```

يعمل الاكتشاف على مستويين:
1. **دقيق** — يوفر LM Studio `capabilities.tool_use` عبر نقطة النهاية الغنية `/api/v1/models`
2. **استدلالي** — لجميع المزودين الآخرين، تتم مطابقة النماذج مع قائمة سماح معروفة من العائلات القادرة على الأدوات (qwen2.5/3، llama3.x، mistral، mixtral، deepseek-r1/v3، command-r، phi3/4، gemma2/3، granite3.x)

النماذج التي لا تتطابق مع أي من الفحصين يتم استبعادها عندما يكون `--tools-only` نشطاً. قد تحتاج قائمة السماح إلى تحديثات مع إطلاق عائلات نماذج جديدة.

## دعم متعدد المزودين

يعمل مع 8 مزودين للاستدلال المحلي. يتم اكتشاف المزود تلقائياً حسب المنفذ، أو حدده بـ `-p`.

| المزود | المنفذ الافتراضي | بيانات وصفية غنية | اكتشاف تلقائي |
|--------|:----------------:|:-----------------:|:-------------:|
| **Ollama** | 11434 | `/api/show` (سياق، عائلات) | ✅ |
| **LM Studio** | 1234 | `/api/v1/models` (نوع، قدرات، سياق) | ✅ |
| **vLLM** | 8000 | أساسي فقط | ✅ |
| **llama.cpp** | 8080 | `/props` (context_size) | ✅ (كـ localai) |
| **LocalAI** | 8080 | أساسي فقط | ✅ |
| **text-generation-webui** | 5000 | أساسي فقط | ✅ |
| **Jan.ai** | 1337 | أساسي فقط | ✅ |
| **GPT4All** | 4891 | أساسي فقط | ✅ |

```bash
# اكتشاف تلقائي حسب المنفذ
./generate_opencode_config.sh -l http://localhost:1234       # LM Studio
./generate_opencode_config.sh -l http://localhost:8000       # vLLM

# مزود صريح
./generate_opencode_config.sh -l http://localhost:8080 -p llama-cpp

# Ollama + LM Studio معاً
./generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio
```

يظهر كل مزود ككتلة منفصلة في `opencode.json`:

```json
{
  "provider": {
    "ollama": { "name": "Ollama", "options": { "baseURL": "http://localhost:11434/v1" }, ... },
    "lmstudio": { "name": "LM Studio", "options": { "baseURL": "http://localhost:1234/v1" }, ... }
  }
}
```

## ذاكرة التخزين المؤقت للبحث عن السياق

يتم تخزين أطوال السياق من `/api/show` مؤقتاً في `~/.cache/opencode-generator/` حسب تجزئة URL. تنتهي صلاحية الذاكرة المؤقتة بعد 24 ساعة. تعيد عمليات التشغيل اللاحقة استخدام القيم المخزنة مؤقتاً وتجلب النماذج الجديدة فقط. استخدم `--no-cache` للتعطيل.

## وضع الدمج

استخدم `--merge` لتحديث النماذج في `opencode.json` موجود دون الكتابة فوق الإعدادات الأخرى (مزودين مخصصين، سمات، قواعد، إلخ):

```bash
# التوليد الأولي
./generate_opencode_config.sh -o opencode.json

# إضافة مزودين مخصصين وقواعد وغيرها يدوياً إلى opencode.json

# لاحقاً: تحديث النماذج فقط، الاحتفاظ بكل شيء آخر
./generate_opencode_config.sh --merge -o opencode.json
```

## إزالة التكرار

إذا كان نفس النموذج موجوداً على خوادم متعددة، تحصل كل نسخة على اسم فريد مع لاحقة الخادم:

```
qwen2.5-coder:7b                → الخادم المحلي (الاسم الأصلي)
qwen2.5-coder:7b@gpu-server     → الخادم البعيد الأول
qwen2.5-coder:7b@gpu-server-2   → الخادم البعيد الثاني بنفس اسم المضيف
```

يظهر كلا الإصدارين في `/models`. يُظهر الملخص النماذج التي تمت إضافة لاحقة لها.

## متغيرات البيئة

| المتغير | الوصف |
|---------|-------|
| `OLLAMA_HOST` | عنوان URL الافتراضي لـ Ollama المحلي (متغير Ollama القياسي) |
| `XDG_CACHE_HOME` | المسار الأساسي لدليل ذاكرة التخزين المؤقت |

## تثبيت التكوين المُولَّد

```bash
# التكوين العام (جميع المشاريع)
cp opencode.json ~/.config/opencode/opencode.json

# خاص بالمشروع
cp opencode.json /path/to/project/opencode.json
```

## استكشاف الأخطاء وإصلاحها

### "تعذر الاتصال بـ Ollama"

- تأكد من أن Ollama يعمل: `ollama serve`
- تحقق من عنوان URL: `curl http://localhost:11434/api/tags`
- إذا كنت تستخدم منفلاً/مضيفاً مخصصاً، عيّن `OLLAMA_HOST` أو استخدم `-l`

### "التبعيات المطلوبة مفقودة: python3"

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows: تنزيل من https://python.org
```

### طول سياق خاطئ

- يستخدم السكريبت `/api/show` افتراضياً للقيم الدقيقة
- إذا كانت API بطيئة، استخدم `--no-context-lookup` للتقديرات الثابتة
- تجاوز يدوياً في JSON المُولَّد إذا لزم الأمر

### نماذج التضمين مُضمنة/مستبعدة بشكل غير متوقع

- تحقق من العائلات في مخرج `ollama show <model>`
- استخدم `--with-embed` للإجبار على التضمين
- استخدم `--exclude "*embed*"` للإجبار على الاستبعاد بالاسم

### "أرجع المزود خطأً" في OpenCode

- بعض نماذج Ollama لا تدعم استدعاء الأدوات — جرّب `qwen2.5-coder` أو `llama3.2`
- زد `num_ctx` إذا فشلت الأدوات: `--num-ctx 32768`
- تأكد من تحميل النموذج: `ollama run <model>`
