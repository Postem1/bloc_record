module BlocRecord

  class Collection < Array
    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def take(num=1)
      if num > 1
        self[0..(num-1)]
      else
        self.first
      end
    end

    def where(arg)
      attr = arg.keys[0]
      self.select { |obj| obj[attr] == arg[attr] }
    end

    def not(arg)
      attr = arg.keys[0]
      self.select { |obj| obj[attr] != arg[attr] }
    end
  end
end
