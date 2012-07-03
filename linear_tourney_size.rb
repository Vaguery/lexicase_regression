# exploring what happens when using Lee Spector's lexicase selection for linear regression

def reality(x, a=2.5,b=9.0)
  a*x+b
end

@expected_values = (-20..20).inject(Hash.new(nil)) {|h,i| h[i] = reality(i); h }
puts "target data: #{@expected_values.inspect}\n\n"

class LinearModel
  attr_accessor :a,:b,:c,:d,:e
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

class NonlinearModel < LinearModel
  attr_accessor :c,:d,:e
  
  def initialize(a,b,c=0.0,d=0.0,e=0.0)
    @a, @b, @c, @d, @e = a,b,c,d,e
  end
  
  def estimate(x)
    @a*x + @b + @c*x*x + @d*x*x*x + @e*x*x*x*x
  end
end



# let's grab a few hundred arbitrary models
# wrong_ones = 1000.times.collect {LinearModel.new(rand()*200-100.0,rand()*200-100.0)}

wrong_ones = 1000.times.collect {
  NonlinearModel.new(
    rand()*200-100.0,
    rand()*200-100.0,
    rand()*10-5.0,
    rand()*10-5.0,
    rand()*10-5.0)}

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

@global_counter=0

def lexicase_tournament_winner(tournament,objective_names, quantile=0.5,counter=@global_counter)
  objective_names.shuffle!
  tournament.shuffle!
  counter = 0
  objective_names.each do |criterion|
    break if tournament.length <= 1
    counter += 1
    extremes = tournament.collect {|dude| dude.abs_errors[criterion]}.minmax
    median = (extremes[1]-extremes[0])*quantile + extremes[0]
    tournament = tournament.find_all {|dude| dude.abs_errors[criterion] <= median}
  end
  @global_counter += counter
  return tournament.sample
end


# for a variety of different tournament sizes (number of samples initially drawn before partitioning)
# THIS WILL TAKE A WHILE!

partition_counts = Hash.new(0)
samples = [2,4,8,16,32,64,128,250,500,1000]
samples.each do |s|
  puts "sample size of 1000 population: #{s}"
  @global_counter = 0
  10000.times do
    tourney = @results.keys.sample(s)
    picked_one = lexicase_tournament_winner(tourney,@expected_values.keys,0.8)
    @results[picked_one][:selections][s] += 1
  end
  partition_counts[s] = @global_counter
end

puts "\n\n#{partition_counts.inspect}\n\n"

puts "\n\ntarget\n2.5,9.0,0.0,0.0,?\n\na,b,sse,sae,2,4,8,16,32,64,128,250,500,1000"
output_line = ""
@results.sort_by {|k,v| v[:sse]}.each do |key,value|
  output_line = "#{key.a},#{key.b},#{value[:sse]},#{value[:sae]}"
  samples.each {|inc| output_line += ",#{value[:selections][inc]}"}
  puts "#{output_line}\n"
end

