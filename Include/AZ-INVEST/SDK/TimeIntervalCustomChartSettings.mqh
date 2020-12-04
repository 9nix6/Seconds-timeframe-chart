#include <AZ-INVEST/SDK/CommonSettings.mqh>

#ifdef DEVELOPER_VERSION
   #define CUSTOM_CHART_NAME "TimeIntervalChart_TEST"
#else
   #define CUSTOM_CHART_NAME "Interval Chart"
#endif

//
// Tick chart specific settings
//
#ifdef SHOW_INDICATOR_INPUTS
   
      input int            intervalMultiple = 30;                    // Bar duration in seconds
            ENUM_INTERVAL  interval = INTERVAL_SECONDS;              // Interval multiple
      input int            showNumberOfDays = 5;                     // Show history for number of days
      input ENUM_BOOL      resetOpenOnNewTradingDay = true;          // Synchronize first bar's open on new day
   
#else // don't SHOW_INDICATOR_INPUTS 

      int            intervalMultiple = 30;                    // Bar duration in seconds
      ENUM_INTERVAL  interval = INTERVAL_SECONDS;              // Interval multiple
      int            showNumberOfDays = 5;                     // Show history for number of days
      ENUM_BOOL      resetOpenOnNewTradingDay = true;          // Synchronize first bar's open on new day

#endif

//
// Remaining settings are located in the include file below.
// These are common for all custom charts
//
#include <az-invest/sdk/CustomChartSettingsBase.mqh>

struct TIMEINTERVALCHART_SETTINGS
{
   int            intervalMultiple;
   ENUM_INTERVAL  interval;
   int            showNumberOfDays;
   ENUM_BOOL      resetOpenOnNewTradingDay;   
   
   long           barTimeInterval;
   int            countdown;
};

class CTimeIntervalCustomChartSettigns : public CCustomChartSettingsBase
{
   protected:
      
   TIMEINTERVALCHART_SETTINGS settings;

   public:
   
   CTimeIntervalCustomChartSettigns();
   ~CTimeIntervalCustomChartSettigns();

   TIMEINTERVALCHART_SETTINGS GetTimeIntervalChartSettings() { return this.settings; };   
   
   virtual void SetCustomChartSettings();
   virtual string GetSettingsFileName();
   virtual uint CustomChartSettingsToFile(int handle);
   virtual uint CustomChartSettingsFromFile(int handle);
};

void CTimeIntervalCustomChartSettigns::CTimeIntervalCustomChartSettigns()
{
   settingsFileName = GetSettingsFileName();
   
   // calculate interval
   settings.barTimeInterval = (long)_INTERVAL_MULT[interval] * (long)intervalMultiple;
}

void CTimeIntervalCustomChartSettigns::~CTimeIntervalCustomChartSettigns()
{
}

string CTimeIntervalCustomChartSettigns::GetSettingsFileName()
{
   return CUSTOM_CHART_NAME+(string)ChartID()+".set";  
}

uint CTimeIntervalCustomChartSettigns::CustomChartSettingsToFile(int file_handle)
{
   return FileWriteStruct(file_handle,this.settings);
}

uint CTimeIntervalCustomChartSettigns::CustomChartSettingsFromFile(int file_handle)
{
   return FileReadStruct(file_handle,this.settings);
}

void CTimeIntervalCustomChartSettigns::SetCustomChartSettings()
{
   //settings.barSizeInTicks = barSizeInTicks;
   settings.interval = interval;
   settings.intervalMultiple = intervalMultiple;
   settings.showNumberOfDays = showNumberOfDays;
   settings.resetOpenOnNewTradingDay = resetOpenOnNewTradingDay;
}
