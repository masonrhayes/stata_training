using DataFrames, CSV, StatsBase, Plots, GLM, Random

rng = MersenneTwister(2)

world = CSV.read("data/world.csv", DataFrame)

describe(world)
names(world)

function pop_category(population)
    population ≤ 10_000_000 ? "small" : 10_000_000 < population ≤ 100_000_000 ? "medium" : "large"
end

transform!(world, :Population => (x -> pop_category.(x)) => :pop_category)


combine(groupby(world, :pop_category), nrow => :num_countries, [:Population, :Area] .=> mean, :Population => sum => :total_population)
