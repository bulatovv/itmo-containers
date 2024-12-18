FROM python:3.12-slim-bookworm as builder
# Фиксированная версия, "урезанный" slim образ
# Mulsti-stage сборка, отделяем сборку артефактов от использования


# Не сохраняем байт-код python на диск, это не нужно в докер контейнере (т.к. они stateless)
# Отключаем буферизацию вывода, чтобы не потерять его при краше
# Увеличиваем timeout для обращения к pypi, повышаем надеждность сборки
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    POETRY_CACHE_DIR='/root/.cache/pypoetry' \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_REQUESTS_TIMEOUT=60

# Используем кэш-маунты, храним кэш пакетов вне образа между билдами
# Ускоряем сборку, даже если поменяли какие-то зависимости
# Устанавливаем только необходимые зависимости 
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends gcc build-essential

# Фиксируем версию
RUN pip install poetry==1.8.0

WORKDIR /app
COPY pyproject.toml poetry.lock ./
# Опять кэш-маунты, но уже для python пакетов, а не для системных
# Не устанавливаем зависимости для разработки и тестирования, уменьшаем размер образа
RUN --mount=type=cache,target=${POETRY_CACHE_DIR} \
    poetry install --without dev,test --no-root

FROM python:3.12-slim-bookworm
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV='/app/.venv' \
    PATH=/app/.venv/bin:$PATH

WORKDIR /app
# Копируем из builder только зависимости, нужные для работы приложеия
COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY main.py ./

# Exec форма, нормальное поведение для сигналов
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
