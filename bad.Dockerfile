FROM python:latest
# Версия не закреплена, чревато проблемой при ломающем обновлении
# Не минималистичный образ, лучше использовать slim образы для Debian или Alpine образы

ENV POETRY_VIRTUALENVS_IN_PROJECT=true \
    VIRTUAL_ENV='/app/.venv' \
    PATH=/app/.venv/bin:$PATH

RUN apt-get update && apt-get install -y gcc build-essential
# Тянем зависимости сборки в итоговый образ
# Можем поставить зависимости, которые нам не нужны

# Не фиксированная версия
RUN pip install poetry

WORKDIR /app

# Копируем код раньше, чем зависимости
# При каждом изменении кода будем заного ставить зависимости
# потому что кэш всех последующих слоев инвалидируется
COPY main.py ./

COPY pyproject.toml poetry.lock ./

RUN poetry install --no-root

VOLUME /app/data

# Shell-форма, плохо работает обработка сигналов
CMD uvicorn main:app --host 0.0.0.0
