# 📱 Numbers Info App

Мобильное Flutter-приложение, которое получает информацию о числах с сервиса [numbersapi.com](http://numbersapi.com).

## 🧩 Функции:
- Выбор категории: Trivia / Math / Date
- Ввод числа вручную
- Получение информации и отображение в модальном окне
- Обработка ошибок
- Возможность расширения (добавить сохранения)

## 🧠 Как работает код

### 1. main() и запуск
- `main()` запускает всё приложение через `runApp()`
- `NumbersApp` задаёт тему и открывает главный экран `NumberInfoPage`

### 2. NumberInfoPage — главный экран
- Содержит поле для ввода числа
- Dropdown для выбора категории (trivia, math, date)
- Кнопка "Получить информацию"
- Показывает результат или ошибку

### 3. API-запрос
- `fetchNumberInfo()` отправляет запрос на `http://numbersapi.com`
- Показывает результат пользователю
- При ошибке (не число или нет интернета) вызывается `showError()`

### 4. Интерфейс
- `TextField`, `DropdownButton`, `ElevatedButton`, `Text`, `CircularProgressIndicator`

### 5. Возможные доработки:
- Добавить кнопку "Сохранить"
- Экран с сохранёнными данными
- Использование Hive или Provider

## 📷 Скриншоты и видео:
[добавь скриншот приложения или .mp4 файл, если есть]

## 🛠 Как запустить:
```bash
git clone https://github.com/M-Ali-2010/numbers_app.git 
cd flutter-numbersapp
flutter pub get
flutter run
```

## 📦 Используемые пакеты:
- `http`: для работы с API
- `provider` или `shared_preferences` — можно подключить для сохранения

## 👤 Автор проекта

- 👨‍💻 Имя: Жураханов Мухаммад Али
- 📧 Email: alimuhammad2010267@gmail.com
- 💬 Telegram: [@Jrkhnv777](https://t.me/Jrkhnv777)
- 🐙 GitHub: [github.com/M-Ali-2010](https://github.com/M-Ali-2010)
