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

A module to save/load interest rates for currencies.

This module saves/loads interest rate data to/from Chronicle. 

```
my $ir_data = Quant::Framework::InterestRate->new(symbol => 'USD',
        rates => { 7 => 0.5, 30 => 1.2, 90 => 2.4 });
$ir_data->save;
```

To read interest rates for a currency:

```
my $ir_data = Quant::MarketData::InterestRate->new(symbol => 'USD');

my $rates = $ir_data->rates;
```
 
##Quant::Framework::ImpliedRate

A module to save/load implied interest rates for currencies.

This module saves/loads implied interest rate data to/from Chronicle. 

```
my $ir_data = Quant::Framework::ImpliedRate->new(symbol => 'USD-EUR',
        rates => { 7 => 0.5, 30 => 1.2, 90 => 2.4 });
$ir_data->save;
```

To read implied interest rates for a currency:

```
my $ir_data = Quant::Framework::ImpliedRate->new(symbol => 'USD-EUR');

my $rates = $ir_data->rates;
``` 
 
##Quant::Framework::Asset

Assets have a symbol and rates. Example assets are currencies, indices, stocks
and commodities.


##Quant::Framework::Currency

The representation of currency within our system

```
my $currency = Quant::Framework::Currency->new({ symbol => 'AUD'});
```

##Quant::Framework::CorrelationMatrix

Correlations have an index, a currency, and duration that corresponds
to a correlation. An example of a correlation is SPC, AUD, 1M, with
a correlation of 0.42.
The values can be updated through backoffice's Quant Market Data page.


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


##Quant::Framework::Exchange
##Quant::Framework::Holiday
##Quant::Framework::PartialTrading
##Quant::Framework::TradingCalendar
##Quant::Framework::ExpiryConventions
##Quant::Framework::VolSurface
