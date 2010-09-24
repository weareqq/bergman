class Movie
  attr_accessor :name, 
                :year, 
                :length,
                :extra
                
                
  def initialize(n, l)
    @name = n
    @length = l
  end
  
end