\📱 Numbers Info App

Интерактивное Flutter-приложение, которое предоставляет занимательные факты о числах через NumbersAPI. Современный интерфейс, реализация Material 3 и возможность сохранения любимых фактов.

✨ Возможности

🔢 Выбор категории: Trivia / Math / Date
🔍 Ввод чисел вручную
⚡ Получение данных с numbersapi.com
✅ Обработка ошибок и отсутствия интернета
💾 Сохранение понравившихся фактов
🎨 Интерфейс с поддержкой Material 3 + Google Fonts
🚀 Быстрый старт

git clone https://github.com/M-Ali-2010/numbers_app.git
cd numbers_app
flutter pub get
flutter run
🧠 Архитектура приложения

main.dart
Настройка темы (Material 3, цвета, шрифты)
Запуск главного экрана NumberInfoPage
NumberInfoPage
UI: Dropdown, TextField, Buttons
Логика:
fetchNumberInfo() — запрос к API
showResultDialog() — вывод результата
SharedPreferences — сохранение данных
SavedItemsPage
Отображение сохранённых фактов
Удаление через свайп
📦 Используемые пакеты

Пакет	Назначение
http	API-запросы
shared_preferences	Хранение локальных данных
google_fonts	Современные шрифты
flutter/material	UI и структура
🛠 Возможности для доработки

Поиск по сохранённым фактам
Темная тема
Экспорт сохранений
Использование Hive или Provider для архитектуры
📸 Скриншоты

(Добавьте сюда изображения UI или гиф/видео)

👨‍💻 Автор

Имя: Жураханов Мухаммад Али
📧 alimuhammad2010267@gmail.com
🐙 GitHub: M-Ali-2010
💬 Telegram: @Jrkhnv777
📍 Ташкент
Хочешь — я могу сгенерировать README.md файл и добавить его в твой проект.
