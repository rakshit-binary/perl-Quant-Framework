# perl-Quant-Framework
A framework of objects upon which to build Financial Quantitative Analysis code

This framework contains modules for different market data that will be needed to price a derivative contract. These market-data modules will need an instance of `Data::Chronicle::Reader` to read data from storage or `Data::Chronicle::Writer` to write data to storage.

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

Assets have a symbol and rates. Example assets are currencies, indices, stocks
and commodities.


##Quant::Framework::Currency

The representation of currency.

```
my $currency = Quant::Framework::Currency->new({ symbol => 'AUD'});
```

##Quant::Framework::CorrelationMatrix

Correlations have an index, a currency, and duration that corresponds
to a correlation. An example of a correlation is SPC, AUD, 1M, with
a correlation of 0.42.

##Quant::Framework::Dividend

This module saves/loads dividends data to/from Chronicle. 
To save dividends for a company:

```
my $corp_dividends = Quant::Framework::Dividends->new(symbol => $symbol,
        rates => { 1 => 0, 2 => 1, 3=> 0.04 }
        discrete_points => { '2015-04-24' => 0, '2015-09-09' => 0.134 });
$corp_dividends->save;
```

To read dividends information for a company:

```
my $corp_dividends = Quant::Framework::Dividends->new(symbol => $symbol);

my $rates = $corp_dividends->rates;
my $disc_points = $corp_dividends->discrete_points;
```

##Quant::Framework::EconomicEventsCalendar

Represents an economic event in the financial market

```
     my $eco = Quant::Framework::EconomicEventCalendar->new({
        recorded_date => $dt,
        events => $arr_events
     });
```

##Quant::Framework::Exchange

Quant::Framework::Exchange - A module to save/load exchange information

##Quant::Framework::Holiday

A module to save/load market holidays

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
