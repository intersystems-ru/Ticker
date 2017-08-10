/// Загрузчик данных о торговле акциями.
/// Описание API Информационно-статистического сервера Московской Биржи:
/// http://www.moex.com/a2193 и http://fs.moex.com/files/6523
Class Ticker.Loader [ Abstract ]
{

/// Загрузить информацию о тикерах начиная с From и заканчивая To. Purge - удалить все записи перед началом загрузки
/// Формат From, To - YYYY-MM-DD
/// Write $System.Status.GetErrorText(##class(Ticker.Loader).Populate())
ClassMethod Populate(From As %Date(DISPLAY=3) = "2013-03-25", To As %Date(DISPLAY=3) = {$ZDate($Horolog,3)}, Purge As %Boolean = {$$$YES})
{
	#Dim Status As %Status = $$$OK
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

/// Получить URL с информацией об акциях за дату Date, пропустить первые Start записей
ClassMethod GetURL(Date, Start As %Integer = 0) [ CodeMode = expression ]
{
$$$FormatText("http://iss.moex.com/iss/history/engines/stock/markets/shares/boards/tqbr/securities.xml?date=%1&start=%2", Date, Start)
}

/// Удалить все данные
ClassMethod Purge()
{
	Do ##class(Ticker.Data).%KillExtent()
}

}

