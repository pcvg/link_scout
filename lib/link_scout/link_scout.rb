module LinkScout

  def self.run(*args)
    case true
    when args[0].is_a?String
    when args[0].is_a?Array
    when args[0].is_a?Hash
    end
  end
end
