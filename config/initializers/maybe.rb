class Maybe
  def initialize(obj)
    @obj = obj
  end

  def method_missing(meth, *args, &block)
    if @obj.nil?
      self
    elsif @obj.respond_to?(meth)
      Maybe.new(@obj.send(meth, *args, &block))
    else
      Maybe.new(nil)
    end
  end

  def just
    @obj
  end
end

class Object
  def maybe
    Maybe.new(self)
  end
end
