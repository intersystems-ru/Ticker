# Ticker
Интеграция с API Московской Биржи для InterSystems Caché.

# Установка 

1. Загрузите и скомпилируйте код [релиза](https://github.com/intersystems-ru/Ticker/releases) в любую область 
2. Выполните в терминале: 
```
Write $System.Status.GetErrorText(##class(Ticker.Loader).Populate())
Do ##class(%DeepSee.Utils).%BuildCube("TICKER")
```
