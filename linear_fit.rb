# exploring what happens when using Lee Spector's lexicase selection for linear regression

def reality(x, a=2.5,b=9.0)
  a*x+b
end

@expected_values = (-20..20).inject(Hash.new(nil)) {|h,i| h[i] = reality(i); h }
puts "target data: #{@expected_values.inspect}\n\n"

class LinearModel
  attr_accessor :a,:b
  attr_accessor :abs_errors
  
  def initialize(a,b)
    @a, @b = a,b
  end
  
  def estimate(x)
    @a*x+@b
  end
  
  def abs_error_at(x,expected=@expected_values)
    (self.estimate(x)-expected[x]).abs
  end
  
  def evaluate(expected)
    @abs_errors = Hash.new(nil)
    expected.each {|x,y| @abs_errors[x] = abs_error_at(x,expected)}
  end
  
  def sum_squared_error(expected)
    self.evaluate(expected)
    @abs_errors.values.inject(0) {|sum,err| sum+(err*err) }
  end
  
  def sum_absolute_error(expected)
    self.evaluate(expected)
    @abs_errors.values.inject(0) {|sum,err| sum+err }
  end
end



# let's grab a few hundred arbitrary linear models
wrong_ones = 1000.times.collect {LinearModel.new(rand()*200-100.0,rand()*200-100.0)}
wrong_ones.each {|model| model.evaluate(@expected_values)}


# we can set them up with some traditional error measures
@results = Hash.new(nil)
wrong_ones.each do |model|
  @results[model] = {sse: model.sum_squared_error(@expected_values)}
  @results[model][:sae] = model.sum_absolute_error(@expected_values)
  @results[model][:selections] = Hash.new(0)
end


# lexicase tournaments:
# start with a "tournament" of variants being compared;
# select the "objectives" (in this case, individual absolute errors) in a random order
# for each objective in turn, discard all individuals with worse than median performance;
# return a random one of those (assuming more than one might remain)

def lexicase_tournament_winner(tournament,objective_names, quantile=0.5)
  objective_names.shuffle!
  tournament.shuffle!
  objective_names.each do |criterion|
    break if tournament.length <= 1
    extremes = tournament.collect {|dude| dude.abs_errors[criterion]}.minmax
    median = (extremes[1]-extremes[0])*quantile + extremes[0]
    tournament = tournament.find_all {|dude| dude.abs_errors[criterion] <= median}
  end
  return tournament.sample
end


# for a variety of different selection "pressures" (quantile kept at each x value)
# THIS WILL TAKE A WHILE!
quantiles = [0.01,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.99]
quantiles.each do |increment|
  puts "quantile retained in each partition: #{increment}"
  10000.times do
    picked_one = lexicase_tournament_winner(@results.keys,@expected_values.keys,increment)
    @results[picked_one][:selections][increment] += 1
  end
end

puts "\n\ntarget\n2.5,9.0,0.0,0.0,?\n\na,b,sse,sae,0.01,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.99"
output_line = ""
@results.sort_by {|k,v| v[:sse]}.each do |key,value|
  output_line = "#{key.a},#{key.b},#{value[:sse]},#{value[:sae]}"
  quantiles.each {|inc| output_line += ",#{value[:selections][inc]}"}
  puts "#{output_line}\n"
end

