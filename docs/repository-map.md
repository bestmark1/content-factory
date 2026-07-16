# Карта репозитория

```text
content-factory/
├── README.md
├── QUICKSTART.md
├── AGENTS.md
├── LICENSE.md
│
├── agents/
│   ├── researcher.md
│   ├── article-researcher.md
│   ├── planner.md
│   └── writer.md
│
├── skills/
│   ├── pipeline-core.md
│   ├── good-writing/
│   │   ├── SKILL.md
│   │   ├── antipatterns.md
│   │   └── writer-checklist.md
│   ├── write-article/
│   ├── write-essay/
│   ├── write-overview/
│   ├── write-guide/
│   ├── redpolicy-article/
│   ├── redpolicy-essay/
│   ├── redpolicy-overview/
│   ├── redpolicy-guide/
│   └── learn/
│
├── scripts/
│   └── lint-text.sh
│
├── templates/
│   ├── project-profile.md
│   ├── content-type-profile.md
│   ├── redpolicy-template.md
│   ├── example-pack.md
│   └── quality-checklist.md
│
├── docs/
│   ├── architecture.md
│   ├── customization.md
│   ├── add-content-type.md
│   ├── install.md
│   ├── publishing-checklist.md
│   ├── smoke-test.md
│   ├── system-overview.md
│   └── repository-map.md
│
├── examples/
│   └── README.md
│
├── input/
│   ├── .gitkeep
│   └── demo-smoke-test.md
│
└── output/
    └── .gitkeep
```

## Логика структуры

`agents/` хранит роли.

`skills/` хранит переиспользуемые инструкции и конвейеры. Общие шаги всех `write-*` скиллов лежат в `skills/pipeline-core.md`; в самих `write-*` — только специфика формата.

`scripts/` хранит исполняемые проверки. `lint-text.sh` ловит механические антипаттерны поиском по шаблонам — запускается на финальной проверке.

`templates/` хранит заполняемые файлы для проекта пользователя.

`docs/` объясняет, как использовать и адаптировать систему.

`examples/` хранит эталонные тексты пользователя. В публичный экспорт реальные примеры не включены.

`input/` и `output/` пустые, потому что реальные исходники и готовые тексты должны оставаться локальными.
