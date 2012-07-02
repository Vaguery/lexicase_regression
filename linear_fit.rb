# exploring what happens when using Lee Spector's lexicase selection for linear regression

def reality(x, a=2.5,b=9.0)
  a*x+b
end

@expected_values = (-20..20).inject(Hash.new(nil)) {|h,i| h[i] = reality(i); h }
puts "data: #{@expected_values.inspect}"

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
end

wrong_ones = 100.times.collect {LinearModel.new(rand()*100-50.0,rand()*100-50.0)}
wrong_ones.each {|model| model.evaluate(@expected_values)}

