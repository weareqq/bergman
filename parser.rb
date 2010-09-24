class Parser
  def self.parse(line)
    movie = extract_movie(line)
    minutes = extract_length(movie)

    unless minutes 
      raise "Format not recognized for length #{movie[:length]} in line '#{line}'"
    end
    #if minutes == 0 || minutes > 300 
    #  puts minutes
    #  
    #  log(movie) 
    #end
    
    Movie.new(movie[:name], minutes)
  end
  
  protected
  def self.extract_movie(line)
    line = line.split("\t")
    fs = line.delete_if{|f| f == ""}
    {:name => fs[0], :length =>fs[1], :extra =>fs[2], :original => line}
  end

  def self.extract_length(movie)
    initial_guess = movie[:length].strip[/(?:.*:)?(.*)/, 1]
    guess = nil

    if initial_guess.index(/\D/)
      # Strange chars in the length
      case initial_guess

      when /(\d+)\s*episodes\s*of\s*(\d+)\s*min/
        # Russia:16 episodes of 52 minutes
        guess =  $1.to_f * $2.to_f

      when /(\d+)\s*episodes?\s*[x|X]\s*(\d+)/
        # Russia:26 episode x 30
        guess =  $1.to_f * $2.to_f

      when /(\d+)\.(\d+)/
        # South Africa:11.5
        guess =  initial_guess

      when /(\d+)\s*[x|X]\s*(\d+)/
        # Sweden:3x59
        guess =  $1.to_f * $2.to_f

      when /(\d+)\s*\+\s*(\d+)/
        # Soviet Union:76+82(2 episodes)
        guess =  $1.to_f + $2.to_f

      when /(\d+)hr/
        # USA:2hr
        guess =  $1.to_f * 60

      when /(\d+)['|,](\d+)/
        # Germany:43'30
        # Czech Republic:18,45
        guess =  "#{$1}.#{$2}".to_f

      when /(\d+)\s*mins?/
        # USA:120 mins
        guess =  $1.to_f

      end
      
      if guess
        log = "."#"Strange: '#{initial_guess}' Guess: '#{guess}'  -- #{movie[:original]}" 
      else
        log = "****** Strange: '#{initial_guess}' *** NO GUESS  -- #{movie[:original]}" 
      end
      File.open("calculation.log", 'a') {|f| f.write(log) }
    else
      guess = initial_guess
    end
    
    guess.to_f 
  end
  def self.log(movie)
    puts " #{movie[:name].ljust(95)} ===========>     #{movie[:length].rjust(5)} min." 
  end
end