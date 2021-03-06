//#define DEVELOPER_VERSION
//#define DISPLAY_DEBUG_MSG
#define MQL5_MARKET_VERSION

//#define P_RENKO_BR_PRO
//#define ULTIMATE_RENKO_LICENSE
//#define RANGEBAR_LICENSE
#define SECONDSCHART_LICENSE
//#define TICKCHART_LICENSE (obsolete)
//#define VOLUMECHART_LICENSE
//#define LINEBREAKCHART_LICENSE

#ifdef P_RENKO_BR_PRO
   #include <AZ-INVEST/SDK/MedianRenkoIndicator.mqh>
   #define AZINVEST_CCI MedianRenkoIndicator
#endif

#ifdef TICKCHART_LICENSE
   #include <AZ-INVEST/SDK/TickChartIndicator.mqh>
   #define AZINVEST_CCI TickChartIndicator
#endif 

#ifdef RANGEBAR_LICENSE
   #include <AZ-INVEST/SDK/RangeBarIndicator.mqh>
   #define AZINVEST_CCI RangeBarIndicator
#endif 

#ifdef ULTIMATE_RENKO_LICENSE
   #include <AZ-INVEST/SDK/MedianRenkoIndicator.mqh>
   #define AZINVEST_CCI MedianRenkoIndicator
#endif 

#ifdef SECONDSCHART_LICENSE
   #include <AZ-INVEST/SDK/SecondsChartIndicator.mqh>
   #define AZINVEST_CCI SecondsChartIndicator
#endif 

#ifdef VOLUMECHART_LICENSE
   #include <AZ-INVEST/SDK/VolumeChartIndicator.mqh>
   #define AZINVEST_CCI VolumeChartIndicator
#endif

#ifdef LINEBREAKCHART_LICENSE
   #include <AZ-INVEST/SDK/LineBreakChartIndicator.mqh>
   #define AZINVEST_CCI LineBreakChartIndicator
#endif


#ifdef AZINVEST_CCI
   AZINVEST_CCI customChartIndicator;
#endif

