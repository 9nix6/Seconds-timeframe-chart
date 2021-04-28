#property copyright "Copyright 2018-2021, Level Up Software"
#property link      "https://www.az-invest.eu"

#ifdef DEVELOPER_VERSION
   #define SECONDS_INDICATOR_NAME "TimeIntervalChart\\SecondsChart101" 
#else
   #ifdef SECONDSCHART_LICENSE
      #ifdef MQL5_MARKET_VERSION
         #define SECONDS_INDICATOR_NAME "Market\\Seconds timeframe chart" 
      #else 
         #define SECONDS_INDICATOR_NAME "SecondsTfChart"
      #endif   
   #else  
      #define SECONDS_INDICATOR_NAME "Market\\Seconds timeframe chart" 
   #endif
#endif

//
//  Data buffer offset values
//
#define SECONDS_OPEN               00
#define SECONDS_HIGH               01
#define SECONDS_LOW                02
#define SECONDS_CLOSE              03 
#define SECONDS_BAR_COLOR          04
#define SECONDS_SESSION_RECT_H     05
#define SECONDS_SESSION_RECT_L     06
#define SECONDS_MA1                07
#define SECONDS_MA2                08
#define SECONDS_MA3                09
#define SECONDS_MA4                10
#define SECONDS_CHANNEL_HIGH       11
#define SECONDS_CHANNEL_MID        12
#define SECONDS_CHANNEL_LOW        13
#define SECONDS_BAR_OPEN_TIME      14
#define SECONDS_TICK_VOLUME        15
#define SECONDS_REAL_VOLUME        16
#define SECONDS_BUY_VOLUME         17
#define SECONDS_SELL_VOLUME        18
#define SECONDS_BUYSELL_VOLUME     19
#define SECONDS_RUNTIME_ID         20

#include <az-invest/sdk/TimeIntervalCustomChartSettings.mqh>

class SecondsChart
{
   private:
   
      CTimeIntervalCustomChartSettigns * secondsChartSettings;

      int secondsChartHandle; //  custom chart indicator handle
      string secondsChartSymbol;
      bool usedByIndicatorOnCustomChart;
   
      datetime prevBarTime;    

   public:
      
      SecondsChart();   
      SecondsChart(bool isUsedByIndicatorOnCustomChart);   
      SecondsChart(string symbol);
      ~SecondsChart(void);
      
      int Init();
      void Deinit();
      bool Reload();
      void ReleaseHandle();
      
      int  GetHandle(void) { return secondsChartHandle; };
      double GetRuntimeId();

      bool IsNewBar();
      
      bool GetMqlRates(MqlRates &ratesInfoArray[], int start, int count);
      bool GetBuySellVolumeBreakdown(double &buy[], double &sell[], double &buySell[], int start, int count);      
      bool GetMA(int MaBufferId, double &MA[], int start, int count);
      bool GetChannel(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);

      // The following 6 functions are deprecated, please use GetMA & GetChannelData functions instead 
      bool GetMA1(double &MA[], int start, int count);
      bool GetMA2(double &MA[], int start, int count);
      bool GetMA3(double &MA[], int start, int count);
      bool GetDonchian(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);
      bool GetBollingerBands(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);
      bool GetSuperTrend(double &SuperTrendHighArray[], double &SuperTrendArray[], double &SuperTrendLowArray[], int start, int count); 
      //

   private:

      int GetIndicatorHandle(void);
      bool GetChannelData(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);   
};

SecondsChart::SecondsChart(void)
{
   #ifdef IS_DEBUG
      Print(__FUNCTION__);
   #endif

   secondsChartSettings = new CTimeIntervalCustomChartSettigns();
      
   secondsChartHandle = INVALID_HANDLE;
   secondsChartSymbol = _Symbol;
   usedByIndicatorOnCustomChart = false;
   prevBarTime = 0;
}

SecondsChart::SecondsChart(bool isUsedByIndicatorOnCustomChart)
{
   #ifdef IS_DEBUG
      Print(__FUNCTION__);
   #endif

   secondsChartSettings = new CTimeIntervalCustomChartSettigns();

   secondsChartHandle = INVALID_HANDLE;
   secondsChartSymbol = _Symbol;
   usedByIndicatorOnCustomChart = isUsedByIndicatorOnCustomChart;
   prevBarTime = 0;
}

SecondsChart::SecondsChart(string symbol)
{
   #ifdef IS_DEBUG
      Print(__FUNCTION__);
   #endif

   secondsChartSettings = new CTimeIntervalCustomChartSettigns();

   secondsChartHandle = INVALID_HANDLE;
   secondsChartSymbol = symbol;
   usedByIndicatorOnCustomChart = false;
   prevBarTime = 0;
}

SecondsChart::~SecondsChart(void)
{
   #ifdef IS_DEBUG
      Print(__FUNCTION__);
   #endif
   
   if(secondsChartSettings != NULL)
   {
      delete secondsChartSettings;
      secondsChartSettings = NULL;  
   }
}

void SecondsChart::ReleaseHandle()
{ 
   if(secondsChartHandle != INVALID_HANDLE)
   {
      IndicatorRelease(secondsChartHandle); 
      secondsChartSettings = NULL;
   }
}

//
//  Function for initializing the custom chart indicator handle
//

int SecondsChart::Init()
{
   if(!MQLInfoInteger((int)MQL5_TESTING))
   {
      if(usedByIndicatorOnCustomChart) 
      {
         //
         // Indicator on customchart uses the values of the custom chart for calculations
         //      
         
         IndicatorRelease(secondsChartHandle);
         secondsChartHandle = GetIndicatorHandle();
         return secondsChartHandle;
      }
   
      if(!secondsChartSettings.Load())
      {
         if(secondsChartHandle != INVALID_HANDLE)
         {
            // could not read new settings - keep old settings
            
            return secondsChartHandle;
         }
         else
         {
            Print("Failed to load indicator settings - Seconds tf chart indicator not on chart");
            return INVALID_HANDLE;
         }
      }   
      
      if(secondsChartHandle != INVALID_HANDLE)
         Deinit();

   }
   else
   {
      if(usedByIndicatorOnCustomChart)
      {
         //
         // Indicator on custom chart uses the values of the custom chart for calculations
         //      
         secondsChartHandle = GetIndicatorHandle();
         return secondsChartHandle;      
      }
      else
      {     
         #ifdef SHOW_INDICATOR_INPUTS
            //
            //  Load settings from EA inputs
            //
            secondsChartSettings.Load();
         #endif
      }
   }   

   TIMEINTERVALCHART_SETTINGS s = secondsChartSettings.GetTimeIntervalChartSettings(); 
   CHART_INDICATOR_SETTINGS cis = secondsChartSettings.GetChartIndicatorSettings(); 
   
   secondsChartHandle = iCustom(this.secondsChartSymbol, _Period, SECONDS_INDICATOR_NAME,                                        
                                       s.intervalMultiple,
                                       s.showNumberOfDays, 
                                       s.resetOpenOnNewTradingDay,
                                       "-",
                                       showPivots,
                                       pivotPointCalculationType,
                                       "-",
                                       AlertMeWhen,
                                       AlertNotificationType,
                                       "-",
                                       cis.MA1lineType,
                                       cis.MA1period,
                                       cis.MA1method,
                                       cis.MA1applyTo,
                                       cis.MA1shift,
                                       cis.MA1priceLabel,
                                       cis.MA2lineType,
                                       cis.MA2period,
                                       cis.MA2method,
                                       cis.MA2applyTo,
                                       cis.MA2shift,
                                       cis.MA2priceLabel,
                                       cis.MA3lineType,
                                       cis.MA3period,
                                       cis.MA3method,
                                       cis.MA3applyTo,
                                       cis.MA3shift,
                                       cis.MA3priceLabel,
                                       cis.MA4lineType,
                                       cis.MA4period,
                                       cis.MA4method,
                                       cis.MA4applyTo,
                                       cis.MA4shift,
                                       cis.MA4priceLabel,
                                       "-",
                                       cis.ShowChannel,
                                       cis.ChannelPeriod,
                                       cis.ChannelAtrPeriod,
                                       cis.ChannelAppliedPrice,
                                       cis.ChannelMultiplier,
                                       cis.ChannelBandsDeviations, 
                                       cis.ChannelPriceLabel,
                                       cis.ChannelMidPriceLabel,
                                       "-",
                                       true); // used in EA
// --- all remaining settings are left at defaults since they have no impact on the EA ---
// TopBottomPaddingPercentage,
// showCurrentBarOpenTime,
// SoundFileBull,
// SoundFileBear,
// DisplayAsBarChart
// ShiftObj
      
    if(secondsChartHandle == INVALID_HANDLE)
    {
      Print(SECONDS_INDICATOR_NAME+" indicator init failed on error ",GetLastError());
    }
    else
    {
      Print(SECONDS_INDICATOR_NAME+" indicator init OK");
    }
     
    return secondsChartHandle;
}

//
// Function for reloading the custom chart indicator if needed
//

bool SecondsChart::Reload()
{
   bool actionNeeded = false;
   int temp = GetIndicatorHandle(); // TODO: further optimization to be done here
   
   if(temp != secondsChartHandle)
   {
      IndicatorRelease(secondsChartHandle); 
      secondsChartHandle = INVALID_HANDLE;

      actionNeeded = true;
   }
   
   if(secondsChartSettings.Changed(GetRuntimeId()))
   {
      actionNeeded = true;      
   }
   
   if(actionNeeded)
   {
      if(secondsChartHandle != INVALID_HANDLE)
      {
         IndicatorRelease(secondsChartHandle); 
         secondsChartHandle = INVALID_HANDLE;
      }

      if(Init() == INVALID_HANDLE)
         return false;
         
      return true;
   }    

   return false;
}

//
// Function for releasing the custom chart indicator handle - free resources
//

void SecondsChart::Deinit()
{
   if(secondsChartHandle == INVALID_HANDLE)
      return;
   
   if(!usedByIndicatorOnCustomChart)
   {
      if(IndicatorRelease(secondsChartHandle))
         Print(SECONDS_INDICATOR_NAME+" indicator handle released");
      else 
         Print("Failed to release "+SECONDS_INDICATOR_NAME+" indicator handle");
   }
}

//
// Function for detecting a new bar on custom chart
//

bool SecondsChart::IsNewBar()
{
   MqlRates currentBar[1];   
   GetMqlRates(currentBar,0,1);
   
   if(currentBar[0].time == 0)
   {
      return false;
   }
   
   if(prevBarTime < currentBar[0].time)
   {
      prevBarTime = currentBar[0].time;
      return true;
   }

   return false;
}

//
// Get "count" MqlRates into "ratesInfoArray[]" array starting from "start" bar  
// SECONDS_BAR_COLOR value is stored in ratesInfoArray[].spread
//

bool SecondsChart::GetMqlRates(MqlRates &ratesInfoArray[], int start, int count)
{
   double o[],l[],h[],c[],barColor[],time[],tick_volume[],real_volume[];

   if(ArrayResize(o,count) == -1)
      return false;
   if(ArrayResize(l,count) == -1)
      return false;
   if(ArrayResize(h,count) == -1)
      return false;
   if(ArrayResize(c,count) == -1)
      return false;
   if(ArrayResize(barColor,count) == -1)
      return false;
   if(ArrayResize(time,count) == -1)
      return false;
   if(ArrayResize(tick_volume,count) == -1)
      return false;
   if(ArrayResize(real_volume,count) == -1)
      return false;

  
   if(CopyBuffer(secondsChartHandle,SECONDS_OPEN,start,count,o) == -1)
      return false;
   if(CopyBuffer(secondsChartHandle,SECONDS_LOW,start,count,l) == -1)
      return false;
   if(CopyBuffer(secondsChartHandle,SECONDS_HIGH,start,count,h) == -1)
      return false;
   if(CopyBuffer(secondsChartHandle,SECONDS_CLOSE,start,count,c) == -1)
      return false;
   if(CopyBuffer(secondsChartHandle,SECONDS_BAR_OPEN_TIME,start,count,time) == -1)
      return false;
   if(CopyBuffer(secondsChartHandle,SECONDS_BAR_COLOR,start,count,barColor) == -1)
      return false;
   if(CopyBuffer(secondsChartHandle,SECONDS_TICK_VOLUME,start,count,tick_volume) == -1)
      return false;
   if(CopyBuffer(secondsChartHandle,SECONDS_REAL_VOLUME,start,count,real_volume) == -1)
      return false;

   if(ArrayResize(ratesInfoArray,count) == -1)
      return false; 
   
   int tempOffset = count-1;
   for(int i=0; i<count; i++)
   {
      ratesInfoArray[tempOffset-i].open = o[i];
      ratesInfoArray[tempOffset-i].low = l[i];
      ratesInfoArray[tempOffset-i].high = h[i];
      ratesInfoArray[tempOffset-i].close = c[i];
      ratesInfoArray[tempOffset-i].time = (datetime)time[i];
      ratesInfoArray[tempOffset-i].tick_volume = (long)tick_volume[i];
      ratesInfoArray[tempOffset-i].real_volume = (long)real_volume[i];
      ratesInfoArray[tempOffset-i].spread = (int)barColor[i];
   }
   
   ArrayFree(o);
   ArrayFree(l);
   ArrayFree(h);
   ArrayFree(c);
   ArrayFree(barColor);
   ArrayFree(time);
   ArrayFree(tick_volume);   
   ArrayFree(real_volume);   
   
   return true;
}

bool SecondsChart::GetBuySellVolumeBreakdown(double &buy[], double &sell[], double &buySell[], int start, int count)
{
   double b[],s[],bs[];
   
   if(ArrayResize(b,count) == -1)
      return false;
   if(ArrayResize(s,count) == -1)
      return false;
   if(ArrayResize(bs,count) == -1)
      return false;

   if(CopyBuffer(secondsChartHandle,SECONDS_BUY_VOLUME,start,count,b) == -1)
      return false;
   if(CopyBuffer(secondsChartHandle,SECONDS_SELL_VOLUME,start,count,s) == -1)
      return false;
   if(CopyBuffer(secondsChartHandle,SECONDS_BUYSELL_VOLUME,start,count,bs) == -1)
      return false;

   if(ArrayResize(buy,count) == -1)
      return false; 
   if(ArrayResize(sell,count) == -1)
      return false; 
   if(ArrayResize(buySell,count) == -1)
      return false; 

   int tempOffset = count-1;
   for(int i=0; i<count; i++)
   {
      buy[tempOffset-i] = b[i];
      sell[tempOffset-i] = s[i];
      buySell[tempOffset-i] = bs[i];
   }
   
   ArrayFree(b);
   ArrayFree(s);
   ArrayFree(bs);
   
   return true;


}

//
// Get "count" values for MaBufferId buffer into "MA[]" array starting from "start" bar  
//

bool SecondsChart::GetMA(int MaBufferId, double &MA[], int start, int count)
{
   double tempMA[];
   if(ArrayResize(tempMA, count) == -1)
      return false;

   if(ArrayResize(MA, count) == -1)
      return false;
   
   if(MaBufferId != SECONDS_MA1 && MaBufferId != SECONDS_MA2 && MaBufferId != SECONDS_MA3 && MaBufferId != SECONDS_MA4)
   {
      Print("Incorrect MA buffer id specified in "+__FUNCTION__);
      return false;
   }
   
   if(CopyBuffer(secondsChartHandle, MaBufferId,start,count,tempMA) == -1)
   {
      return false;
   }
   
   for(int i=0; i<count; i++)
   {
      MA[count-1-i] = tempMA[i];
   }

   ArrayFree(tempMA);      
   return true;
}

//
// Get "count" MovingAverage1 values into "MA[]" array starting from "start" bar  
//

bool SecondsChart::GetMA1(double &MA[], int start, int count)
{
   Print(__FUNCTION__+" is deprecated, please use GetMA instead");
   
   double tempMA[];
   if(ArrayResize(tempMA,count) == -1)
      return false;

   if(ArrayResize(MA,count) == -1)
      return false;
   
   if(CopyBuffer(secondsChartHandle,SECONDS_MA1,start,count,tempMA) == -1)
      return false;

   for(int i=0; i<count; i++)
   {
      MA[count-1-i] = tempMA[i];
   }

   ArrayFree(tempMA);      
   return true;
}

//
// Get "count" MovingAverage2 values into "MA[]" starting from "start" bar  
//

bool SecondsChart::GetMA2(double &MA[], int start, int count)
{
   Print(__FUNCTION__+" is deprecated, please use GetMA instead");
   
   double tempMA[];
   if(ArrayResize(tempMA,count) == -1)
      return false;

   if(ArrayResize(MA,count) == -1)
      return false;
   
   if(CopyBuffer(secondsChartHandle,SECONDS_MA2,start,count,tempMA) == -1)
      return false;
   
   for(int i=0; i<count; i++)
   {
      MA[count-1-i] = tempMA[i];
   }
   
   ArrayFree(tempMA);   
   return true;
}

//
// Get "count" MovingAverage3 values into "MA[]" starting from "start" bar  
//

bool SecondsChart::GetMA3(double &MA[], int start, int count)
{
   Print(__FUNCTION__+" is deprecated, please use GetMA instead");
   
   double tempMA[];
   if(ArrayResize(tempMA,count) == -1)
      return false;

   if(ArrayResize(MA,count) == -1)
      return false;
   
   if(CopyBuffer(secondsChartHandle,SECONDS_MA3,start,count,tempMA) == -1)
      return false;
   
   for(int i=0; i<count; i++)
   {
      MA[count-1-i] = tempMA[i];
   }
   
   ArrayFree(tempMA);   
   return true;
}

//
// Get "count" Donchian channel values into "HighArray[]", "MidArray[]", and "LowArray[]" arrays starting from "start" bar  
//

bool SecondsChart::GetDonchian(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count)
{
   Print(__FUNCTION__+" is deprecated, please use GetChannelData instead");
   return GetChannel(HighArray,MidArray,LowArray,start,count);
}

//
// Get "count" Bollinger band values into "HighArray[]", "MidArray[]", and "LowArray[]" arrays starting from "start" bar  
//

bool SecondsChart::GetBollingerBands(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count)
{
   Print(__FUNCTION__+" is deprecated, please use GetChannelData instead");
   return GetChannel(HighArray,MidArray,LowArray,start,count);
}

//
// Get "count" SuperTrend values into "HighArray[]", "MidArray[]", and "LowArray[]" arrays starting from "start" bar  
//

bool SecondsChart::GetSuperTrend(double &SuperTrendHighArray[], double &SuperTrendArray[], double &SuperTrendLowArray[], int start, int count)
{
   Print(__FUNCTION__+" is deprecated, please use GetChannelData instead");
   return GetChannel(SuperTrendHighArray,SuperTrendArray,SuperTrendLowArray,start,count);
}

//
// Get Channel values into "HighArray[]", "MidArray[]", and "LowArray[]" arrays starting from "start" bar  
//

bool SecondsChart::GetChannel(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count)
{
   return GetChannelData(HighArray,MidArray,LowArray,start,count);
}

//
// Private function used by GetDonchian and GetBollingerBands functions to get data
//

bool SecondsChart::GetChannelData(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count)
{
   double tempH[], tempM[], tempL[];

   if(ArrayResize(tempH,count) == -1)
      return false;
   if(ArrayResize(tempM,count) == -1)
      return false;
   if(ArrayResize(tempL,count) == -1)
      return false;

   if(ArrayResize(HighArray,count) == -1)
      return false;
   if(ArrayResize(MidArray,count) == -1)
      return false;
   if(ArrayResize(LowArray,count) == -1)
      return false;
   
   if(CopyBuffer(secondsChartHandle,SECONDS_CHANNEL_HIGH,start,count,tempH) == -1)
      return false;
   if(CopyBuffer(secondsChartHandle,SECONDS_CHANNEL_MID,start,count,tempM) == -1)
      return false;
   if(CopyBuffer(secondsChartHandle,SECONDS_CHANNEL_LOW,start,count,tempL) == -1)
      return false;
   
   int tempOffset = count-1;
   for(int i=0; i<count; i++)
   {
      HighArray[tempOffset-i] = tempH[i];
      MidArray[tempOffset-i] = tempM[i];
      LowArray[tempOffset-i] = tempL[i];
   }   
   
   ArrayFree(tempH);
   ArrayFree(tempM);
   ArrayFree(tempL);
   
   return true;
}

int SecondsChart::GetIndicatorHandle(void)
{
   int i = ChartIndicatorsTotal(0,0);
   int j=0;
   string iName;
   
   while(j < i)
   {
      iName = ChartIndicatorName(0,0,j);
      if(StringFind(iName, CUSTOM_CHART_NAME) != -1)
      {
         return ChartIndicatorGet(0,0,iName);   
      }   
      
      j++;
   }
   
   Print("Failed getting handle of "+CUSTOM_CHART_NAME);
   return INVALID_HANDLE;
}

double SecondsChart::GetRuntimeId()
{
   double runtimeId[1];
    
   if(CopyBuffer(secondsChartHandle, SECONDS_RUNTIME_ID, 0, 1, runtimeId) == -1)
      return -1;

   return runtimeId[0];   
}