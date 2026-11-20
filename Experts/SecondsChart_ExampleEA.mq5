#property copyright "Copyright 2019-2026, Level Up"
#property link      "https://www.az-invest.eu"
#property version   "1.00"
#property description "Example EA showing the way to use the SecondsChart class defined in SecondsChart.mqh" 
//#define DEVELOPER_VERSION

//
// EDITION: which Seconds chart indicator does this EA load?
// -------------------------------------------------------------------------------------------------
// Left commented, the EA loads the MQL5 Market edition ("Market\Seconds timeframe chart").
// If you bought the indicator from https://www.az-invest.eu/seconds-timeframe-chart-for-metatrader-5
// uncomment the line below, so the EA loads "SecondsTfChart" instead, and recompile.
// The switch in CustomBarConfig.mqh does not reach an EA: this line is the one that decides.
//

//#define SECONDSCHART_LICENSE

input int InpRSIPeriod = 14; // RSI period

//
// SHOW_INDICATOR_INPUTS *NEEDS* to be defined, if the EA needs to be *tested in MT5's backtester*
// -------------------------------------------------------------------------------------------------
// Using '#define SHOW_INDICATOR_INPUTS' will show the Seconds chart indicator's inputs 
// NOT using the '#define SHOW_INDICATOR_INPUTS' statement will read the settigns from the chart with 
// the Seconds chart indicator attached.
//

//#define SHOW_INDICATOR_INPUTS

//
// You need to include the SecondsChart.mqh header file. It defines the SecondsChart class.
//

#include <AZ-INVEST/SDK/SecondsChart.mqh>
//
//  To use the Seconds chart indicator in your EA you need do instantiate the indicator class (SecondsChart)
//  and call the Init() and Deinit() methods in your EA's OnInit() and OnDeinit() functions.
//  Example shown below
//

SecondsChart *secondsChart = NULL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if(secondsChart == NULL)
   {
      secondsChart = new SecondsChart(MQLInfoInteger((int)MQL_TESTER) ? false : true);
   }
   
   secondsChart.Init();
   if(secondsChart.GetHandle() == INVALID_HANDLE)
      return(INIT_FAILED);
   
   //
   //  your custom code goes here...
   //
      
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(secondsChart != NULL)
   {
      secondsChart.Deinit();
      delete secondsChart;
      secondsChart = NULL;
   }
   
   //
   //  your custom code goes here...
   //
}

//
//  At this point, you may use the seconds chart data fetching methods in your EA.
//  Brief demonstration presented below in the OnTick() function:
//

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

int rsiHandle = INVALID_HANDLE; // Handle for the external RSI indicator

void OnTick()
{
   //
   // Initialize all additional indicators here! (not in the OnInit() function).
   // Otherwise they will not work in the backtest.
   // When backtesting please select the "Daily" timeframe.
   //
   
   if(rsiHandle == INVALID_HANDLE)
   {
      rsiHandle = iCustom(_Symbol, _Period, "SecondsTfChart\\RSI", InpRSIPeriod);
   }

   //
   // It is considered good trading & EA coding practice to perform calculations
   // when a new bar is fully formed. 
   // The IsNewBar() method is used for checking if a new seconds chart bar has formed 
   //
      
   if(secondsChart.IsNewBar())
   {  
      //
      //  There are two methods for getting the Moving Average values.
      //  The example below gets the moving average values for 3 latest bars
      //  counting to the left from the most current (uncompleted) bar.
      //
      
      int startAtBar = 0;   // get value starting from the most current (uncompleted) bar.
      int numberOfBars = 3; // gat a total of 3 MA values (for the 3 latest bars)
      
      //
      // Values will be stored in 2 arrays defined below
      //
      
      double MA1[]; // array to be filled by values of the first moving average
      double MA2[]; // array to be filled by values of the second moving average
      
      if(secondsChart.GetMA(SECONDS_MA1, MA1, startAtBar, numberOfBars) && secondsChart.GetMA(SECONDS_MA2, MA2, startAtBar, numberOfBars))
      {
         //
         // Values are stored in the MA1 and MA2 arrays and are now ready for use
         //
         // MA1[0] contains the 1st moving average value for the latest (uncompleted) bar
         // MA1[1] contains the 1st moving average value for the 1st bar to the left from the latest (uncompleted) bar
         // MA1[2] contains the 1st moving average value for the 2nd bar to the left from the latest (uncompleted) bar
         // MA1[3]..MA1[n] do not exist since we retrieved the values for 3 bars (defined by "numnberOfBars")
         //
         // The values for the 2nd and 3rd moving average are stored in MA2[] & MA3[] 
         // and are accessed identically to values of MA1[] (shown above)
      }
      
      //
      // Getting the MqlRates info for seconds chart bars is done using the
      // GetMqlRates(MqlRates &ratesInfoArray[], int start, int count) 
      // method. Example below:
      //
      
      MqlRates SecondsChartRatesInfoArray[]; // This array will store the MqlRates data for the seconds chart
      startAtBar = 0;                     // get values starting from the last completed bar.
      numberOfBars = 3;                   // gat a total of 3 MqlRates values (for 3 bars starting from bar 0 (current uncompleted))
      
      if(secondsChart.GetMqlRates(SecondsChartRatesInfoArray,startAtBar,numberOfBars))
      {         
         //
         //  Check if a reversal bar has formed
         //
       
         string infoString;
         
         if((SecondsChartRatesInfoArray[1].open < SecondsChartRatesInfoArray[1].close) &&
            (SecondsChartRatesInfoArray[2].open > SecondsChartRatesInfoArray[2].close))
         {
            // bullish reversal
            infoString = "Previous bar formed bullish reversal";
         }
         else if((SecondsChartRatesInfoArray[1].open > SecondsChartRatesInfoArray[1].close) &&
            (SecondsChartRatesInfoArray[2].open < SecondsChartRatesInfoArray[2].close))
         {
            // bearish reversal
            infoString = "Previous bar formed bearish reversal";
         }
         else
         {
            infoString = "";
         }
      
         //
         //  Output some data to chart
         //
      
         Comment("\nNew bar opened on "+(string)SecondsChartRatesInfoArray[0].time+
                 "\nPrevious bar OPEN price:"+DoubleToString(SecondsChartRatesInfoArray[1].open,_Digits)+", bar opened on "+(string)SecondsChartRatesInfoArray[1].time+
                 "\n"+infoString+ 
                 "\n");
      }
      
      //
      // All charts that contain real volume information (i.e. stocks, futures, ...)
      // also contain the brekdown of volume into BUY, SELL and BUY/SELL volume.
      // This data is accessed using
      // GetBuySellVolumeBreakdown(long &buy[], long &sell[], long &buySell[], int start, int count)
      // Example below:
      
      double buyVolume[];      // This array will store the values of the BUY volume 
      double sellVolume[];     // This array will store the values of the SELL volume
      double buySellVolume[];  // This array will store the values of the BUY/SELL volume
      
      // When you add BUY, SELL and BUY/SELL volume numbers for a bar they will be equal 
      // to the Real Volume number that can be accessed using 
      // GetMqlRates(MqlRates &ratesInfoArray[], int start, int count) 
      // as described above.

      startAtBar   = 1;    // get values starting from the last completed bar.
      numberOfBars = 2;    // gat a total of 2 values (for 2 bars starting from bar 1 (last completed))
      
      if(secondsChart.GetBuySellVolumeBreakdown(buyVolume,sellVolume,buySellVolume,startAtBar,numberOfBars))
      {
         //
         // Apply your real volume analysis logic here...
         //         
      }
      
      //
      // Getting the values of the channel indicator (Donchain, Bullinger Bands, Keltner or Super Trend) is done using
      // GetChannel(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count) 
      // Example below:
      //
      
      double HighArray[];  // This array will store the values of the channel's high band
      double MidArray[];   // This array will store the values of the channel's middle band
      double LowArray[];   // This array will store the values of the channel's low band
      
      startAtBar   = 1;    // get values starting from the last completed bar.
      numberOfBars = 20;   // gat a total of 20 values (for 20 bars starting from bar 1 (last completed))
      
      if(secondsChart.GetChannel(HighArray,MidArray,LowArray,startAtBar,numberOfBars))
      {
         //
         // Apply your logic here...
         //
      } 
   } 
}
