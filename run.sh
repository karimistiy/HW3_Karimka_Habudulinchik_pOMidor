
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
case "$1" in
  build_generator)
    echo ">>> Сборка образа генератора..."
    docker build -t data-generator "$PROJECT_DIR/generator"
    ;;
  run_generator)
    echo ">>> Запуск контейнера генератора (результат → data/data.csv)..."
    mkdir -p "$PROJECT_DIR/data"
    docker run --rm \
      -v "$PROJECT_DIR/data:/data" \
      data-generator
    echo ">>> Готово: $PROJECT_DIR/data/data.csv"
    ;;
  create_local_data)
    echo ">>> Создание data.csv локально в local_data/..."
    mkdir -p "$PROJECT_DIR/local_data"
    python3 "$PROJECT_DIR/generator/generate.py" "$PROJECT_DIR/local_data"
    echo ">>> Готово: $PROJECT_DIR/local_data/data.csv"
    ;;

  build_reporter)
    echo ">>> Сборка образа аналитика..."
    docker build -t data-reporter "$PROJECT_DIR/reporter"
    ;;
  run_reporter)
    echo ">>> Запуск контейнера аналитика (результат → data/report.html)..."
    mkdir -p "$PROJECT_DIR/data"
    docker run --rm \
      -v "$PROJECT_DIR/data:/data" \
      data-reporter
    echo ">>> Готово: $PROJECT_DIR/data/report.html"
    ;;
  structure)
    echo ">>> Структура проекта:"
    find "$PROJECT_DIR" -not -path "*/node_modules/*" -not -path "*/.git/*" | sort | \
      awk -F'/' '{
        depth = NF - 1 - '"$(echo "$PROJECT_DIR" | tr -cd '/' | wc -c)"';
        indent = "";
        for (i = 0; i < depth; i++) indent = indent "  ";
        print indent $NF
      }'
    ;;
  clear_data)
    echo ">>> Удаление сгенерированных файлов из data/..."
    rm -f "$PROJECT_DIR/data/"*.csv "$PROJECT_DIR/data/"*.html
    echo ">>> Папка data/ очищена."
    ;;
  inside_generator)
    echo ">>> Содержимое /data внутри контейнера генератора:"
    mkdir -p "$PROJECT_DIR/data"
    docker run --rm \
      -v "$PROJECT_DIR/data:/data" \
      data-generator \
      sh -c "echo '=== Файлы в /data ===' && ls -la /data"
    ;;
  inside_reporter)
    echo ">>> Содержимое /data внутри контейнера аналитика:"
    mkdir -p "$PROJECT_DIR/data"
    docker run --rm \
      -v "$PROJECT_DIR/data:/data" \
      --entrypoint sh \
      data-reporter \
      -c "echo '=== Файлы в /data ===' && ls -la /data"
    ;;
  report_server)
    echo ">>> Запуск веб-сервера для report.html на порту 8080..."
    mkdir -p "$PROJECT_DIR/data"
    docker run --rm -d \
      --name report-server \
      -v "$PROJECT_DIR/data:/usr/share/nginx/html:ro" \
      -p 8080:80 \
      nginx:alpine
    echo ">>> Сервер запущен. Откройте порт 8080 в GitHub Codespaces (вкладка 'Ports')."
    echo ">>> Для остановки: docker stop report-server"
    ;;
  *)
    echo "Использование: $0 {команда}"
    echo ""
    echo "Доступные команды:"
    echo "  build_generator    — собрать образ генератора"
    echo "  run_generator      — запустить генератор → data/data.csv"
    echo "  create_local_data  — создать data.csv локально в local_data/"
    echo "  build_reporter     — собрать образ аналитика"
    echo "  run_reporter       — запустить аналитик → data/report.html"
    echo "  structure          — вывести структуру проекта"
    echo "  clear_data         — удалить .csv и .html из data/"
    echo "  inside_generator   — показать /data изнутри контейнера генератора"
    echo "  inside_reporter    — показать /data изнутри контейнера аналитика"
    echo "  report_server      — запустить nginx-сервер для отчёта на порту 8080"
    ;;
esac
