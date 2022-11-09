classdef EntityMapBase < handle
properties
  impl
end
methods
  function obj = EntityMapBase(impl)
    obj.impl = impl;
  end

  function result = size(self)
    try
      result = self.impl.size();
    catch e
      HandleException(e, 'AMPLAPI:EntityMap:size');
    end
  end

  function result = iterator(self)
    try
      result = EntityIterator(self.impl.iterator());
    catch e
      HandleException(e, 'AMPLAPI:EntityMap:toArray');
    end
  end

  function result = toArray(self)
    try
      result = self.iterator().toArray();
    catch e
      HandleException(e, 'AMPLAPI:EntityMap:toArray');
    end
  end

  function result = toString(self)
    try
      s = self.size();
      if s==0
        result = sprintf('This map contains 0 entities.\n');
      else
        if s == 1
          result = sprintf('This map contains 1 entity:\n');
        else
          result = sprintf('This map contains %d entities:\n', s);
        end
        it = self.iterator();
        while it.hasNext()
            result = sprintf('%s\t%s\n', result, it.next().name);
        end
      end
    catch e
      HandleException(e, 'AMPLAPI:EntityMap:toString');
    end
  end

end
end
