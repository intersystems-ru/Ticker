# Визуализация данных Московской Биржи с помощью InterSystems DeepSee

## Содержание

- Введение
- Получение данных
- ETL
- Построение куба
- Построение сводной таблицы
- Построение дэшборда
- Установка MDX2JSON и DSW
- Визуализация
- Выводы
- Ссылки


## Введение

В стеке технологий InterSystems есть пакет бизнес-аналитики DeepSee. Он предназначен для создания OLAP-решений для баз данных на Caché и любых реляционных СУБД.  В статье рассматривается пример создания в OLAP-куба и работа со средством аналитики источников данных  и пользовательского интерфейса на примере анализа котировок акций торгуемых на Московской Бирже (ММВБ).

## Получение данных

Для визуализации данных о котировках акций торгуемых на бирже необходимо их сначала загрузить. У биржи есть общедоступное задокументированное [API](http://www.moex.com/a2193) которое предоставляет информацию о торговле акциями в форматах HTML, XML, JSON, CSV.  
Вот, к примеру, [XML данные](http://iss.moex.com/iss/history/engines/stock/markets/shares/boards/tqbr/securities.xml?date=2013-05-27) за 27 мая 2013 года. Создадим [XML-Enabled](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=GXML_import) класс `Ticker.Data` в InterSystems Caché:

```
Class Ticker.Data Extends (%Persistent, %XML.Adaptor)
{

/// Дата торгов
Property Date As %Date(FORMAT = 3, XMLNAME = "TRADEDATE", XMLPROJECTION = "attribute");

/// Краткое название компании
Property Name As %String(XMLNAME = "SHORTNAME", XMLPROJECTION = "attribute");

/// Тикер
Property Ticker As %String(XMLNAME = "SECID", XMLPROJECTION = "attribute");

/// Количество сделок
Property Trades As %Integer(XMLNAME = "NUMTRADES", XMLPROJECTION = "attribute");

/// Общая сумма сделок
Property Value As %Decimal(XMLNAME = "VALUE", XMLPROJECTION = "attribute");

/// Цена открытия
Property Open As %Decimal(XMLNAME = "OPEN", XMLPROJECTION = "attribute");

/// Цена закрытия
Property Close As %Decimal(XMLNAME = "CLOSE", XMLPROJECTION = "attribute");

/// Цена закрытия официальная
Property CloseLegal As %Decimal(XMLNAME = "LEGALCLOSEPRICE", XMLPROJECTION = "attribute");

/// Минимальная цена акции
Property Low As %Decimal(XMLNAME = "LOW", XMLPROJECTION = "attribute");

/// Максимальная цена акции
Property High As %Decimal(XMLNAME = "HIGH", XMLPROJECTION = "attribute");

/// Средневзвешенная цена акции http://www.moex.com/s1194
/// Может считаться как за день так и не за период.
Property Average As %Decimal(XMLNAME = "WAPRICE", XMLPROJECTION = "attribute");

/// Количество акций участвовавших в сделках
Property Volume As %Integer(XMLNAME = "VOLUME", XMLPROJECTION = "attribute");

}
```

И напишем загрузчик данных в формате XML. Так как класс у нас XML-Enabled то конвертация из XML в объекты происходит автоматически. Аналогичного поведения можно достичь для данных в форматах JSON (через [динамические объекты](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=GJSON_create)) и CSV (используя [%SQL.Util.Procedures](http://docs.intersystems.com/latest/csp/documatic/%25CSP.Documatic.cls?PAGE=CLASS&LIBRARY=%25SYS&CLASSNAME=%25SQL.Util.Procedures#METHOD_CSVTOCLASS)). Так как биржа отдаёт данные за определённую дату (день) то нам надо итерировать по дням и сохранять поступающие данные. Кроме того данные о котировках акций приходят страницами по 100 записей. Загрузчик может выглядеть так:
```
/// Загрузить информацию об акциях начиная с From и заканчивая To. Purge - удалить все записи перед началом загрузки
/// Формат From, To - YYYY-MM-DD
/// Write $System.Status.GetErrorText(##class(Ticker.Loader).Populate())
ClassMethod Populate(From As %Date(DISPLAY=3) = "2013-03-25", To As %Date(DISPLAY=3) = {$ZDate($Horolog,3)}, Purge As %Boolean = {$$$YES})
{
	#Dim Status As %Status = $$$OK
	// Переводим даты во внутренний формат для простоты итерации
	Set FromH = $ZDateH(From, 3)
	Set ToH = $ZDateH(To, 3)
	
	Do:Purge ..Purge()
	
	For DateH = FromH:1:ToH {
		Write $c(13), "Populating ", $ZDate(DateH, 3)
		Set Status = ..PopulateDay(DateH)
		Quit:$$$ISERR(Status)
	}
	
	Quit Status
}

/// Загрузить данные за день. Данные загружаются страницами по 100 записей. 
/// Write $System.Status.GetErrorText(##class(Ticker.Loader).PopulateDay($Horolog))
ClassMethod PopulateDay(DateH As %Date) As %Status
{
	#Dim Status As %Status = $$$OK
		
	Set Reader = ##class(%XML.Reader).%New()
	Set Date = $ZDate(DateH, 3) // Преобразовать дату из внутреннего формата в YYYY-MM-DD
	Set Count = 0 // Число загруженных записей
	
	While Count '= $G(CountOld) {
		Set CountOld = Count
		Set Status = Reader.OpenURL(..GetURL(Date, Count)) // Получаем следующую страницу данных
		Quit:$$$ISERR(Status)
		
		// Десериализуем каждую ноду row в объект класса Ticker.Data
		Do Reader.Correlate("row", "Ticker.Data")
		While Reader.Next(.Object, .Status) {
			#Dim Object As Ticker.Data
			
			// Созраняем объект
			If Object.Ticker '="" {
				Set Status = Object.%Save()
				Quit:$$$ISERR(Status)
				Set Count = Count + 1
			}
		}
		Quit:(Count-CountOld)<100 // На текущей странице меньше 100 записей => эта страница - последняя
	}
	Quit Status
}

/// Получить URL с информацией о котировках акций за дату Date, пропустить первые Start записей
ClassMethod GetURL(Date, Start As %Integer = 0) [ CodeMode = expression ]
{
$$$FormatText("http://iss.moex.com/iss/history/engines/stock/markets/shares/boards/tqbr/securities.xml?date=%1&start=%2", Date, Start)
}

```

Теперь загрузим данные командой: `Write $System.Status.GetErrorText(##class(Ticker.Loader).Populate())`

Весь код доступен в [репозитории](https://github.com/intersystems-ru/Ticker/).

## ETL

Как известно, для построения любого OLAP-куба в любой BI-технологии в первую очередь необходимо сформировать [таблицу фактов](https://ru.wikipedia.org/wiki/Таблица_фактов): таблицу операций, записи которой требуется группировать и фильтровать. Таблица фактов может быть связана с другими таблицами по схеме [звезда](https://ru.wikipedia.org/wiki/Схема_звезды) или [снежинка](https://ru.wikipedia.org/wiki/Схема_снежинки).

Таблица фактов для куба обычно является результатом работы аналитиков и разработчиков по процессу, который называется [ETL](https://ru.wikipedia.org/wiki/ETL) (extract, transform, load). Т.е. из данных предметной области делается “выжимка” необходимых для анализа данных, и переносится в удобную для хранилища структуру "звезда"/"снежинка": факты и справочники фактов. 
В нашем случае этап ETL пропустим т.к. наш класс `Ticker.Data` уже находятся во вполне удобном для создания куба состоянии.

## Построение куба
## Построение сводной таблицы
## Построение дэшборда
## Установка MDX2JSON и DeepSeeWeb

Для визуализации созданного дэшборда используются следующие OpenSource решения:
- [MDX2JSON](https://github.com/intersystems-ru/Cache-MDX2JSON) - REST API предоставляет информацию о кубах, пивотах, дэшбордах и многих других элементах DeepSee в частности - результатах исполнения MDX запросов.
- [DeepSeeWeb](https://github.com/intersystems-ru/DeepSeeWeb) - AngularJS приложение, предоставляющее альтернативную реализацию портала пользователя DeepSee. Может быть легко кастомизирован. Использует MDX2JSON в качестве бэкэнда.

### Установка MDX2JSON

Для установки MDX2JSON надо:

1. Загрузить [Installer.xml](https://raw.githubusercontent.com/intersystems-ru/Cache-MDX2JSON/master/MDX2JSON/Installer.cls.xml) и импортировать его в любую область с помощью Studio, Портала Управления Системой или `Do $System.OBJ.Load(file)`.
2. Выполнить в терминале (пользователем с ролью %ALL): `Do ##class(MDX2JSON.Installer).setup()`

Для проверки установки надо открыть в браузере страницу `http://server:port/MDX2JSON/Test?Debug`. Возможно потребуется ввести логин и пароль (в зависимости от настроек безопасности сервера). Должна открыться страница с информацией о сервере. В случае получения ошибки, можно почитать на [Readme](https://github.com/intersystems-ru/Cache-MDX2JSON) и [Wiki](https://github.com/intersystems-ru/Cache-MDX2JSON/wiki/Installation-Guide---RU).

### Установка DeepSeeWeb

Для установки DeepSeeWeb надо:

1. Загрузить [установщик](https://github.com/intersystems-ru/DeepSeeWeb/releases) и импортировать его в любую область с помощью Studio, Портала Управления Системой или `Do $System.OBJ.Load(file)`.
2. Выполнить в терминале (пользователем с ролью %ALL): `Do ##class(DSW.Installer).setup()`

Для проверки установки  надо открыть в браузере страницу `http://server:port/dsw/index.html`. Должна открыться станица авторизации.

## Визуализация
## Выводы
## Ссылки

- [Репозиторий](https://github.com/intersystems-ru/Ticker).
- [MDX2JSON](https://github.com/intersystems-ru/Cache-MDX2JSON)
- [DeepSeeWeb](https://github.com/intersystems-ru/DeepSeeWeb)
- [API Московской Биржи](http://www.moex.com/a2193)
