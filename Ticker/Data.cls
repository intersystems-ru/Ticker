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

Storage Default
{
<Data name="DataDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Date</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
<Value name="4">
<Value>Close</Value>
</Value>
<Value name="5">
<Value>Ticker</Value>
</Value>
<Value name="6">
<Value>Trades</Value>
</Value>
<Value name="7">
<Value>Value</Value>
</Value>
<Value name="8">
<Value>Open</Value>
</Value>
<Value name="9">
<Value>Low</Value>
</Value>
<Value name="10">
<Value>High</Value>
</Value>
<Value name="11">
<Value>Average</Value>
</Value>
<Value name="12">
<Value>Volume</Value>
</Value>
<Value name="13">
<Value>CloseLegal</Value>
</Value>
</Data>
<DataLocation>^Ticker.DataD</DataLocation>
<DefaultData>DataDefaultData</DefaultData>
<IdLocation>^Ticker.DataD</IdLocation>
<IndexLocation>^Ticker.DataI</IndexLocation>
<StreamLocation>^Ticker.DataS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

