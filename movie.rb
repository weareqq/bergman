class Movie
  attr_accessor :name, 
                :year, 
                :length,
                :extra
                
                
  def initialize(n, y, l)
    @name = n
    @year = y
    @length = l
  end
  
end