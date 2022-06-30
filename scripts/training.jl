using DataFrames, XLSX, Statistics, PrettyTables

cars_test_without_99 = DataFrame(XLSX.readtable("data/cars_test_without99.xlsx", "cars")...)

cars_test_99 = DataFrame(XLSX.readtable("data/cars_test_99.xlsx", "cars")...)

cars = append!(cars_test_without_99, cars_test_99)

cars

# Create a function to more easily write CSVs to disk
function write_csv(name, df::DataFrame)
    path = "output/$name.csv"
    data = df
    CSV.write(path, data)
end

## CLEANING -----
rename!(cars, :ye => :year)

cars.year = cars.year .+ 1900

## currencies

### find common currency price
transform!(cars, [:pr, :avdexr] => ((x,y) -> x ./ y) => :common_currency_price)

### exporter price 
transform!(cars, [:pr, :avexr] => ((x,y) -> x ./ y) => :exporter_currency_price)

## price in NGDP per capita

transform!(cars, [:pr, :ngdp, :pop] => ((x,y,z) -> x ./ y .* z) => :pr_ngdp_pc)

# Does it make sense? Don't know, no info on exchange rate units
select(cars, [:pr, :pr_ngdp_pc, :common_currency_price, :exporter_currency_price]) |> describe

# 3.3
## remove all observations with zcode == 17
filter!(:zcode => !=(17), cars)

cars.luxury = [class == "luxury" ? 1 : 0 for class in cars.cla]

cars.compact = [class == "compact" ? 1 : 0 for class in cars.cla]

cars.lux_alfa_romeo = [class == "luxury" && brand == "alfa romeo" ? 1 : 0 for (class, brand) in zip(cars.cla,cars.brand)]

select(cars, [:luxury, :compact, :lux_alfa_romeo]) |> describe

## 3.5

# replace "," with "/" in :model

cars.model = [!ismissing(model) ? replace(model, "," => "/") : model for model in cars.model]

# 3.6 & 3.7

cars.obs_num = 1:nrow(cars)

cars.total_obs .= nrow(cars)

# 3.8

transform!(groupby(cars, :brand), nrow => :obs_per_brand)

# 3.9

transform!(groupby(cars, :brand), :pr => mean => :mean_brand_pr)

describe(select(cars, [:pr, :mean_brand_pr]))


combine(groupby(cars, :brand), nrow => :obs_per_band, :mean_brand_pr)

# 4.0 -----
# Tables

table4a = combine(groupby(cars, :cla), [:pr, :we, :le] .=> mean) |> pretty_table

temp = combine(groupby(cars, [:brand, :ma]), nrow => :count)

table4b = sort(unstack(temp, :ma, :count), :brand)


# 4.3 

temp4c = combine(groupby(cars, [:brand, :ma]), [:pr, :qu] => ((x,y) -> sum(x .* y) ./ sum(y)) => :weighted_total_price)

temp4c2 = combine(groupby(cars, [:brand, :ma]), :pr => sum , :pr => mean, nrow => :count)
transform(temp4c2, [:pr_sum, :count] => ((x,y) -> x./y) => :nice)
table4c = unstack(temp4c, :ma, :weighted_total_price)


temp4d = combine(groupby(cars, [:brand, :ma]), :qu => sum)
table4d = unstack(temp4d, :ma, :qu_sum)

# 5

lookup_radio_model = DataFrame(XLSX.readtable("data/lookup_radio_model.xlsx", "Sheet1")...)
rename!(lookup_radio_model, [:brand, :model, :radio])

df = leftjoin(cars, lookup_radio_model, on = [:brand, :model], matchmissing = :equal)

filter(:radio => !ismissing, df)