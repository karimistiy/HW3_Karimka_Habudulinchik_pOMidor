# Docker BI — Домашнее задание №3

Проект генерирует CSV-данные о товарах в магазине и строит HTML-отчёт с помощью двух отдельных Docker-контейнеров.

## Структура проекта

```
project/
├── generator/
│   ├── Dockerfile      # образ на python:3.11-slim
│   └── generate.py     # генерирует data/data.csv
├── reporter/
│   ├── Dockerfile      # образ на node:20-alpine
│   ├── report.js       # читает CSV, пишет report.html
│   └── package.json    # зависимость: csv-parse
├── data/               # общая папка: CSV и HTML (монтируется в оба контейнера)
├── local_data/         # для локальной отладки генератора
├── run.sh              # главный скрипт управления
└── README.md
```

## Быстрый старт

```bash
chmod +x run.sh

# 1. Собрать образы
./run.sh build_generator
./run.sh build_reporter

# 2. Сгенерировать данные
./run.sh run_generator

# 3. Построить отчёт
./run.sh run_reporter
```

После этого в папке `data/` появятся `data.csv` и `report.html`.

## Все команды

| Команда | Описание |
|---|---|
| `./run.sh build_generator` | Собрать Docker-образ генератора |
| `./run.sh run_generator` | Запустить генератор → `data/data.csv` |
| `./run.sh create_local_data` | Создать CSV локально в `local_data/` (для отладки) |
| `./run.sh build_reporter` | Собрать Docker-образ аналитика |
| `./run.sh run_reporter` | Запустить аналитик → `data/report.html` |
| `./run.sh structure` | Вывести структуру файлов проекта |
| `./run.sh clear_data` | Удалить `.csv` и `.html` из `data/` |
| `./run.sh inside_generator` | Показать содержимое `/data` изнутри контейнера генератора |
| `./run.sh inside_reporter` | Показать содержимое `/data` изнутри контейнера аналитика |
| `./run.sh report_server` | Запустить nginx-сервер с отчётом на порту 8080 |

## Как открыть отчёт в браузере через GitHub Codespaces

Отчёт запускается через третий контейнер — `nginx:alpine` — который раздаёт `report.html` по HTTP.

### Пошаговая инструкция

1. Склонируйте репозиторий и откройте его в GitHub Codespaces.

2. Сгенерируйте данные и отчёт:
   ```bash
   chmod +x run.sh
   ./run.sh build_generator && ./run.sh run_generator
   ./run.sh build_reporter  && ./run.sh run_reporter
   ```

3. Запустите веб-сервер:
   ```bash
   ./run.sh report_server
   ```
   Внутри Codespaces запустится контейнер `nginx:alpine`. Он монтирует папку `data/` как корень сайта и слушает порт **80** контейнера, который проброшен на порт **8080** хоста Codespaces.

4. Откройте вкладку **Ports** в нижней панели VS Code (или перейдите в меню *Terminal → Ports*). Найдите строку с портом **8080** и нажмите на иконку глобуса — Codespaces откроет публичный HTTPS-URL вида `https://<id>-8080.app.github.dev`.

5. В браузере вашего компьютера откроется `report.html`.

### Цепочка проброса портов

```
Браузер (ваш ПК)
    ↕  HTTPS (публичный URL Codespaces)
Хост GitHub Codespaces (порт 8080)
    ↕  docker -p 8080:80
nginx-контейнер (порт 80)
    ↕  volume mount
data/report.html
```

6. Для остановки сервера:
   ```bash
   docker stop report-server
   ```
