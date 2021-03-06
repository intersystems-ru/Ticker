/// 
Class Ticker.Cube Extends %DeepSee.CubeDefinition [ DependsOn = Ticker.Data, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="Ticker" displayName="Ticker" disabled="false" abstract="false" sourceClass="Ticker.Data" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0" disableListingGroups="false">
  <dimension name="Ticker" displayName="Тикер" disabled="false" hasAll="false" allCaption="All Ticker" allDisplayName="Ticker" type="data" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Ticker" displayName="Тикер" disabled="false" sourceProperty="Ticker" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
    <additionalDescription>undefined</additionalDescription>
  </dimension>
  <dimension name="Date" displayName="Дата" disabled="false" hasAll="false" allCaption="All Date" allDisplayName="Date" sourceProperty="Date" type="time" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Year" displayName="Год" disabled="false" timeFunction="Year" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Month" displayName="Месяц" disabled="false" timeFunction="MonthYear" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Day" displayName="День" disabled="false" timeFunction="DayMonthYear" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
    <additionalDescription>undefined</additionalDescription>
  </dimension>
  <measure name="Volume" displayName="Объём" disabled="false" sourceProperty="Volume" aggregate="SUM" type="number" hidden="false" searchable="false">
  </measure>
  <measure name="Average" displayName="Средняя цена" disabled="false" sourceProperty="Average" aggregate="MAX" type="number" hidden="false" searchable="false">
  </measure>
  <listing name="Listing" displayName="Листинг" disabled="false" listingType="table" fieldList="Name,Ticker,&quot;Open&quot;,CloseLegal,Low,Average,High">
    <additionalDescription>undefined</additionalDescription>
  </listing>
</cube>
}

Parameter DOMAIN;

}

