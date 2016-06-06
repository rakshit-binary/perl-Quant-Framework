# perl-Quant-Framework
A framework of objects upon which to build Financial Quantitative Analysis code

This framework contains modules for different market data that will be needed to price a derivative contract. These market-data modules will need an instance of `Data::Chronicle::Reader` to read data from storage or `Data::Chronicle::Writer` to write data to storage.

Also note that in all `Quant::Framework` modules you can pass a `for_date` parameter when creating the module to read historical information. In case no `for_date` is provided, modules will work with latest information.

Below is a list of supported modules.

##Quant::Framework::CorporateAction
Represents the corporate actions data of an underlying from database. 

To read actions for a company:
```
my $corp = Quant::Framework::CorporateAction->new(symbol => $symbol,
            chronicle_reader => $reader);
my $actions = $corp->actions;
```
To save actions for a company:
```
my $corp = Quant::Framework::CorporateAction
        ->new(symbol => $symbol, 
            chronicle_writer => $writer,
            actions => {
                1234 => {
                    monitor_date => "2014-02-07",
                    type => "ACQUIS",
                    description => "Acquisition",
                    effective_date => "15-Jul-15",
                    flag => "N", #N means new action, U means updated action, D means cancelled action
                }});
$corp->save();
```
##Quant::Framework::InterestRate

Interest rate is the amount of interest paid for deposit money. This can be defined for different periods and different currencies. So we can have different interest rates for each combination of currency and period. Usually interest rates are described as a percentage. For example a 1% interest rate for a period of 1 year for USD currency means you will get 1.01 times your initial deposit money after one years. For more informatio please refer to [Interest rate](https://en.wikipedia.org/wiki/Interest_rate).

This module helps you save/load interest rates to/from a `Data::Chronicle` storage system. When creating an instance of this module you will need to specify symbol (The name of the currency for which you want to save/load interest rate) and a hash-ref named rates. Rates is a hash-table where key is duration (period in days) and the corresponding value is the interest rate percentage paid after that duration.

To save interest rates:

```
#Here USD is the currency, "7, 30 and 90" are durations and corresponding values "0.5, 1.2 and 2.4" are interest rates

my $ir_data = Quant::Framework::InterestRate->new(
            symbol => 'USD',
            rates => { 
                        7 => 0.5, 
                        30 => 1.2, 
                        90 => 2.4 
                     },
            chronicle_writer => $chronicle_w
            );
            
$ir_data->save;
```

To load interest rates for a currency:

```
my $ir_data = Quant::MarketData::InterestRate->new(
            symbol => 'USD'
            chronicle_reader => $chronicle_r
            );

my $rates = $ir_data->rates;
```
 
##Quant::Framework::ImpliedRate

Implied interest rate is the interest rate for a currency which is implied from :
* Forward price for the currency pair
* Interest rate of the counter-party currency

For example if we have Forward rate for EUR/USD and interest rate for USD, we can calculate implied interest rate for EUR, using the Spot-Forward price relationship.

This module helps you save/load implied interest rates to/from a `Data::Chronicle` storage system. When creating an instance of this module you will need to specify combined symbol (The name of the currency for which you want to save/load implied interest rate and the currency from which you have implied this rates) and a hash-ref named rates. Rates is a hash-table where key is duration (period in days) and the corresponding value is the interest rate percentage paid after that duration.

```
my $ir_data = Quant::Framework::ImpliedRate->new(
            symbol => 'USD-EUR',
            rates => { 
                        7 => 0.5, 
                        30 => 1.2, 
                        90 => 2.4 
                     },
            chronicle_writer => $chronicle_w
            );
            
$ir_data->save;
```

To read implied interest rates for a currency:

```
my $ir_data = Quant::Framework::ImpliedRate->new(
            symbol => 'USD-EUR',
            chronicle_reader => $chronicle_r
            );

my $rates = $ir_data->rates;
``` 
 
##Quant::Framework::Asset

An asset is anything which has value and can be bought and sold. For example in a forex currency pair (EUR/USD) you will be paying/receiving USD when you buy/sell EUR. So here EUR is the asset. Also for indices or stocks you will be paying domestic currency to buy units of index or stock. So Index or Stock are assets.

This module can be used to read dividend rates for an asset. You will need to pass symbol name when instantiating the module.

To instantiate an asset module and read dividend rates:

```
my $asset = Quant::Framework::Asset->new(
            symbol => 'AEX',
            chronicle_reader => $chronicle_r
            );
            
#here $time_in_years is the duration for which we need to get dividend rates.
my $rates = $asset->rate_for($time_in_years);
```

##Quant::Framework::Currency

The representation of currency. You can use this module to query for a currency's interest rates, holidays and query for already saved implied interest rates. This module relies on `Quant::Framework::Holiday` to fetch holiday information for it's currency.

Below example shows how to create instances of this module and query information from that module:

```
my $currency = Quant::Framework::Currency->new(
            symbol => 'AUD',
            chronicle_reader => $chronicle_r
);

#here $time_in_years is the duration for which we need to get dividend rates.
my $rates = $currency->rate_for($time_in_years);

#this call will return a hash-reference whose keys are number of days since epoch and value is description 
#of the holiday.
my $holidays = $currency->holidays;

#this will return a floating number (0 if the days is holiday, 0.5 if it's a pseudo-holiday 
# and 1 if it's a normal trading day)
my $weight = $currency->weight_on(Date::Utility->new('2016-03-21'));

my $is_holiday = $currency->has_holiday_on(Date::Utility->new('2016-1-1');
```

##Quant::Framework::CorrelationMatrix

Correlation matrix is a 2-D array which shows correlation between indices and currencies for different time periods.
Rows of the matrix represent different currencies (e.g. AUD, USD, ...). Columns represent indices (e.g. DJI) and for each cell of the matrix, there is a list of correlations for different time period (e.g. 3 months, 6 months, ...).

This modules is used to load/save a correlation matrix and query for correlations. It relies on `Quant::Framework::ExpiryConventions` to do its calculations.

To save a correlation matrix:

```
my $matrix = Quant::Framework::CorrelationMatrix->new(
            symbol => 'indices',
            chronicle_writer => $chronicle_w
            );
            
#Input data for correlation matrix should be initialized like this:
my $data = ();

$data->{'DJI'}->{'AUD'}->{'3M'} = 0.3;
$data->{'DJI'}->{'JPY'}->{'6M'} = 0.12;
$data->{'DJI'}->{'GBP'}->{'12M'} = 0.83;

$matrix->correlations($data);
$matrix->save;

```

To load correlation matrix and query information:

```
my $matrix = Quant::Framework::CorrelationMatrix->new(
            symbol => 'indices',
            chronicle_reader => $chronicle_r
            );
            
my $time_in_years = 0.5;

#This will return a floating number representing the correlation between DJI index and AUD currency
#over a 6-month period.
my $correlation = $matrix->correlation_for('DJI', 'AUD', $time_in_years, $expiry_conventions);

```

##Quant::Framework::Dividend

Dividend is the capital gains for an underlying after a period of time. For more information please refer to [Dividend](https://en.wikipedia.org/wiki/Dividend).

This module saves/loads dividends data to/from Chronicle and query dividend rates for a specific period of time. 

To save dividends for an underlying:

```
my $dividends = Quant::Framework::Dividends->new(
            symbol => $symbol,
            rates => { 
                        1 => 0, 
                        2 => 1, 
                        3 => 0.04 
                     },
            discrete_points => 
                     { 
                        '2015-04-24' => 0, 
                        '2015-09-09' => 0.134 
                     },
            chronicle_writer => $chronicle_w
            );
$dividends->save;
```

To read dividends information and query rates for an underlying:

```
my $dividends = Quant::Framework::Dividends->new(
            symbol => $symbol,
            chronicle_reader => $chronicle_r
            );

my $rates = $dividends->rates;

my $time_in_years = 0.5;
my $sixmonth_rate = $dividends->rate_for($time_in_years);
```

##Quant::Framework::EconomicEventsCalendar

Represents a calendar of important economic announcement made by central banks (e.g. Unemployment Rate or CPI).
An instance of this module will contain all economic announcement for all underlyings.

To save economic events:

```
my $calendar = Quant::Framework::EconomicEventCalendar->new({
            recorded_date => $dt,
            #events is a list of hash-refs each containing an economic event
            events => [
            {
                source => 'net',
                event_name => 'Labor Market Conditions Index m/m',
                symbol => 'USD',
                release_date => 1465221600, #this is epoch of the release date-time
                recorded_date => Date::Utility->new->epoch, #this is epoch of the time when this record is being saved
                impact => 1  #importance of this event (1 = low impact, 3 = medium impact, 5 = high impact)
            },
            {
                source => 'net',
                event_name => 'Cash Rate',
                symbol => 'AUD',
                release_date => 1465273800,
                recorded_date => Date::Utility->new->epoch, 
                impact => 3
            },
            {
                source => 'net',
                event_name => 'Announcement1',
                symbol => 'JPY',
                release_date => 1465273600,
                recorded_date => Date::Utility->new->epoch, 
                impact => 5,
                is_tentative => 1,
            },
            ],
            chronicle_writer => $chronicle_w
});
$calendar->save;
```

To read an economic event calendar:

```
my $calendar = Quant::Framework::EconomicEventCalendar->new(
            chronicle_reader => $chronicle_r
            );
my @events = @{$calendar->events};
#first_event will be a hash-ref with same structure as the one we used to save economic events.
my $first_event = $events[0];

#here we fetch all economic events whose release_date lies inside the given time period
my $events = $calendar->get_latest_events_for_period(
            from => Date::Utility->new('2015-01-10'),
            to => Date::Utility->new('2015-01-20')
);

#get a list of tentative economic events
my $tentatives = $calendar->get_tentative_events;
            
```

##Quant::Framework::Exchange

Each underlying can only be traded in a specific exchange. As a result of this, some properties of the exchange (e.g. Openning or closing time or holidays) will affect when/how an underlying is being traded.

This module represents basic information about an exchange. More specific information about an exchange (including open/close times) can be get using `TradingCalendar` module. The information you get from this module are stored in the `exchange.yml` file stored in `share` directory of this repository.

To read an exchange information:
```
my $exchange = Quant::Framework::Exchange->new(
            symbol => 'NASDAQ',
);

my $name = $exchange->display_name;
my $currency = $exchange->currency;
my $timezone = $exchange->trading_timezone;

#value of trading_days can be:
# everyday -> 7 days a week
# weekdays -> 5 week-days of week (excluding weekends)
#sun_thru_thu -> from Sunday to Thursday
my $trading_days = $exchange->trading_days;

```

##Quant::Framework::Holiday

This module stored information regarding holidays for exchanges or currencies. Each exchange around the world is closed at certain days through a year same holds for countries. Underlyings whose currency or exchange are closed cannot be traded. So we need these information to make a decision about whether or not offer an underlying.

This module can be used to save/load holiday information and query whether a symbol has a holiday on a certain date.

To save holidays:
```
my $holidays = Quant::Framework::Holiday->new(
            #calendar is a hash-ref whose keys are epochs of the holiday and value is a list of holidays on that day.
            #Each holiday in the list is represented using a hash-ref (key is name of the holiday and value is 
            #    an array containing name of exchanges or currencies which are affected by that holiday).
            calendar => {
                1456790400 => [ 'Independence Movement Day' => [ 'KRX' ],
                                'Independence Day' => ['KRW'] ],
                1472428800 => [ 'Summer Bank Holiday' => [ 'LSE', 'ICE_LIFFE', 'GBP' ] ]
            },
            chronicle_writer => $chronicle_w,
);

$holidays->save;
```

To read holiday information and do queries:

```
my $holidays = Quant::Framework::Holiday->new(
            chronicle_reader => $chronicle_r,
            );
my $calendar = $holidays->calendar;
#this will return all holidays for USD
my $holiday_info = Quant::Framework::Holiday::get_holidays_for($chronicle_r, 'USD');
```

##Quant::Framework::PartialTrading

Partial trading means times when an exchange is opened later than usual (late\_open) or closed earlier than usual (early\_close).

##Quant::Framework::TradingCalendar

This module is responsible for everything related to time-based status of an exchange (whether exchange is open/closed, has holiday, is partially open, ...)
Plus all related helper modules (trading days between two days where exchange is open, trading breaks, DST effect, open/close time, ...).
One important feature of this module is that it is designed for READING information not writing.

```
my $calendar = Quant::Framework::TradingCalendar->new('LSE');
```

##Quant::Framework::ExpiryConventions


##Quant::Framework::VolSurface

Base class for all volatility surfaces.
