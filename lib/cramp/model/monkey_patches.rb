class Arel::Session
  def read(select, &block)
    select.call(&block)
  end
end

class Arel::Relation
  def call(&block)
    engine.read(self, &block)
  end

  def each(&block)
    session.read(self) {|rows| rows.each(&block)}
  end

  def each(&block)
    session.read(self) {|rows| rows.each {|r| block.call(r) } }
  end
end
