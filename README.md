# Backend coding challenge
Ruby on Rails application that automates a calculation of merchants’ disbursements payouts and seQura commissions.
Link to original challenge: https://sequra.github.io/backend-challenge/

Application uses:
 - Ruby version - 3.0.4
 - Rails version - 7.1.2
 - PostgreSQL version - 14.10
 - Sidekiq version - 7.2

## Features
  1. Parsing `merchants.csv` file to validate and save data in `merchants` table
  2. Parsing `orders.csv` file to validate, calculate fee and save data in `orders` table
  3. Calculate monthly fees for all existing merchants from `live on` date to current date
  4. Calculate daily and weekly disbursements for all merchants' orders
  5. Calculate disbursements on daily basis
  6. Calculate disbursements on weekly basis

## Calculations
**Note:** Monthly fee calculations for all merchants are calculated from `live on` date to current date (last calculated month is December 2023), even if there are no orders for December in `orders.csv` file!

Year	| Number of disbursements | Amount disbursed to merchants | Amount of order fees | Number of monthly fees charged (From minimum monthly fee) | Amount of monthly fee charged (From minimum monthly fee) |
------|-------------------------|-------------------------------|----------------------|-----------------------------------------------------------|----------------------------------------------------|
2022  | 1009                    | 29035379.3                    | 262968.56            | 46                                                        | 1072.88                                            |
2023  | 7870                    | 143096726.46                  | 1300058.84           | 214                                                       | 4868.69                                            |


## Files to download (DB dump, .CSV files)
Dropbox link: https://www.dropbox.com/scl/fo/r3x8xnbbmbqnm6s2mujaa/h?rlkey=2x62x65vkbxy2aru05ui4c8iu&dl=0

.CSV files provided via the original challenge are invalid.

## Launch
Before start working with the database, ensure you have the PostgreSQL service running: `brew services list`

1. `git clone git@github.com:denis-mironov/sequra.git`
2. `bundle install`
3. `rake db:create`
4. Filling DB with data:
    - Parsing .CSV files and using rake tasks (***time consuming operation***):
      - `rake db:migrate`
      - `download 'merchants.csv' and 'orders.csv' files via Dropbox link above`
      - `create new 'db/csv_dumps' directory in the project and put downloaded .CSV files there`
      - run next rake tasks:
      - `rake fill_table_with_data:merchants`
      - `rake fill_table_with_data:orders`
      - `rake fill_table_with_data:monthly_fees`
      - `rake disbursements:fill_daily`
      - `rake disbursements:fill_weekly`

    - Using DB dump (merchants, orders, disbursements and monthly_fees are included):
      - `download 'development_dump.sql' file via Dropbox link above`
      - `psql sequra_development < link_to_downloaded_dump_file`
      - `rake db:migrate`

## Check Sidekiq jobs execution
  1. Install and run Redis service ([official Redis documentation](https://redis.io/docs/install/install-redis/install-redis-on-mac-os/))
  2. Run Sidekiq server with `sidekiq` comand.
## Run test files
 - `rspec spec`
## Run rubocop checks
 - `rubocop`
