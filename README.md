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
##Quant::Framework::ImpliedRate
##Quant::Framework::Asset
##Quant::Framework::Currency
##Quant::Framework::CorrelationMatrix
##Quant::Framework::Dividend
##Quant::Framework::EconomicEventsCalendar
##Quant::Framework::Exchange
##Quant::Framework::Holiday
##Quant::Framework::PartialTrading
##Quant::Framework::TradingCalendar
##Quant::Framework::ExpiryConventions
##Quant::Framework::VolSurface
