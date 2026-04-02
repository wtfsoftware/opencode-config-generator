# مولد تكوين OpenCode لـ Ollama

يُنشئ `opencode.json` لـ [OpenCode](https://opencode.ai) بناءً على نماذج خوادم Ollama المحلية والبعيدة.

[English](README.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.3.0** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

---

## الميزات

- **Multi-provider**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- اكتشاف النماذج تلقائيًا عبر واجهة برمجة التطبيقات Ollama
- تصفية نماذج التضمين (nomic-bert وغيرها)
- أطوال السياق الدقيقة عبر `/api/show` (مع احتياطي)
- دعم خوادم Ollama البعيدة المتعددة
- اختيار تفاعلي للنماذج مع خيار "الكل"
- التصفية بأنماط glob (include/exclude)
- الكشف التلقائي عن small_model
- وضع المعاينة (dry-run)
- لواحق الخادم للنماذج المكررة
- الدمج مع التكوين الحالي (merge)
- دعم متغير البيئة `OLLAMA_HOST`

## المتطلبات

| Component | Bash | PowerShell |
|-----------|:----:|:----------:|
| curl | required | not needed |
| Python 3 | required | not needed |
| PowerShell 5.1+ | n/a | required |

## البداية السريعة

```bash
./generate_opencode_config.sh
.\Generate-OpenCodeConfig.ps1
```

## الاستخدام

```bash
./generate_opencode_config.sh -r http://gpu:11434    # remote
./generate_opencode_config.sh -i                      # interactive
./generate_opencode_config.sh --include "qwen*"       # filter
./generate_opencode_config.sh -n                      # dry-run
./generate_opencode_config.sh --merge                 # merge
./generate_opencode_config.sh --default-model qwen2.5-coder:7b
./generate_opencode_config.sh -v                      # version
```

## مرجع CLI

| Flag | Description |
|------|-------------|
| `-l, --local URL` | Local server URL |
| `-r, --remote URL` | Remote URL (repeatable) |
| `-p, --provider NAME` | Provider: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | auto |
| `-o, --output FILE` | Output (`-` for stdout) |
| `-n, --dry-run` | Preview |
| `-i, --interactive` | Interactive selection |
| `--include PAT` | Include pattern |
| `--exclude PAT` | Exclude pattern |
| `--with-embed` | Include embed models |
| `--tools-only` | Only models with tool/function calling support |
| `-ToolsOnly` | Only models with tool/function calling support |
| `--no-context-lookup` | Skip API lookup |
| `--num-ctx N` | num_ctx (0=omit) |
| `--merge` | Merge config |
| `--default-model ID` | Default model |
| `--small-model ID` | Small model |
| `--no-cache` | Disable cache |
| `-v, --version` | Version |

## كيف يعمل

1. **جلب النماذج** من كل خادم عبر `GET /api/tags`
2. **تصفية** نماذج التضمين حسب حقل `families`
3. **تصفية** حسب أنماط include/exclude
4. **جلب أطوال السياق** عبر `POST /api/show` (متوازي، مع ذاكرة تخزين مؤقت)
5. **إزالة التكرار** للنماذج من خوادم متعددة (لواحق `@host:port`)
6. **اختيار تفاعلي** (مع `-i`)
7. **دمج** (مع `--merge`): الحفاظ على الإعدادات الموجودة
8. **الكشف عن small_model**: أصغر نموذج غير تضمين
9. **إنشاء** `opencode.json`

## مثال التكوين

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "options": { "baseURL": "http://localhost:11434/v1" },
      "models": {
        "qwen2.5-coder:7b": {
          "name": "Qwen2 7.6B Q4_K_M (local)",
          "limit": { "context": 32768, "output": 16384 }
        }
      }
    }
  },
  "model": "ollama/qwen2.5-coder:7b"
}
```

## إزالة التكرار

إذا كان نفس النموذج موجودًا على خوادم متعددة، يحصل كل نسخة على اسم فريد بلاحقة الخادم:

```
qwen2.5-coder:7b             → local
qwen2.5-coder:7b@gpu-server  → remote
```

## ذاكرة التخزين المؤقت للسياق

يتم تخزين أطوال السياق مؤقتًا في `~/.cache/opencode-generator/`. تنتهي صلاحية ذاكرة التخزين المؤقت بعد 24 ساعة.

## وضع الدمج

استخدم `--merge` لتحديث النماذج دون الكتابة فوق الإعدادات الأخرى:

```bash
./generate_opencode_config.sh --merge -o opencode.json
```

## تثبيت التكوين

```bash
cp opencode.json ~/.config/opencode/opencode.json
```

## متغيرات البيئة

| Variable | Description |
|----------|-------------|
| `OLLAMA_HOST` | Default Ollama URL |
| `XDG_CACHE_HOME` | Cache directory |

## استكشاف الأخطاء وإصلاحها

### تعذر الاتصال بـ Ollama

- تأكد من أن Ollama يعمل: `ollama serve`
- تحقق من عنوان URL: `curl http://localhost:11434/api/tags`

### تبعيات مفقودة

```bash
sudo apt install python3 curl   # Ubuntu/Debian
brew install python3 curl       # macOS
```

### سياق غير صحيح

- يستخدم البرنامج النصي `/api/show` افتراضيًا
- استخدم `--no-context-lookup` إذا كانت واجهة API بطيئة
