class Arel::Session
  def create(insert, &block)
    insert.call(&block)
  end

  def read(select, &block)
    select.call(&block)
  end

  def update(update, &block)
    update.call(&block)
  end

  def delete(delete, &block)
    delete.call(&block)
  end

end

class Arel::Relation
  def call(&block)
    engine.read(self, &block)
  end

  def all(&block)
    session.read(self) {|rows| block.call(rows) }
  end

  def first(&block)
    session.read(self) {|rows| block.call(rows[0]) }
  end

  def each(&block)
    session.read(self) {|rows| rows.each {|r| block.call(r) } }
  end

  def insert(record, &block)
    session.create(Arel::Insert.new(self, record), &block)
  end

  def update(assignments, &block)
    session.update(Arel::Update.new(self, assignments), &block)
  end

  def delete(&block)
    session.delete(Arel::Deletion.new(self), &block)
  end
end

class Arel::Deletion
  def call(&block)
    engine.delete(self, &block)
  end
end

class Arel::Insert
  def call(&block)
    engine.create(self, &block)
  end
end

class Arel::Update
  def call(&block)
    engine.update(self, &block)
  end
end
