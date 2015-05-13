# download-all-vk-music.coffee
Маленькая программа для скачивания всей музыки [ВК](http://vk.com).

[ПРОСТЕЙШАЯ РАБОТАЮЩАЯ ВЕРСИЯ НА BASH ЗДЕСЬ](https://github.com/upisfree/download-all-vk-music.sh.git)

## Что внутри?
 * Скачивание (как ни странно)
 * Красивенькие имена файлов (типа «Исполнитель — Песня.mp3»)
 * Выбор папки, куда сохранять песни (а мог качать туда, где лежит сама программа)
 * Нет временных файлов
 * Прелестный экран загрузки
  1. Прогресс-бар
  2. Вес (в мегабайтах или процентах) того, что уже скачалось и сколько осталось
  3. Процент загрузки
  4. Сколько песен скачано всего и сколько осталось
  5. Название песни

## Установка
### linux
```bash
# Установка taglib
git clone https://github.com/taglib/taglib.git
cd taglib
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release
make
sudo make install
cd ..
rm -r taglib # хи-хи

# Установка, собственно, скачивальщика (смешное слово)
git clone https://github.com/upisfree/download-all-vk-music.git
cd download-all-vk-music
npm install
```

## Запуск
```bash
node build/download-all-vk-music.js
```
