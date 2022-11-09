classdef EntityIteratorBase < handle
properties
  impl
end
methods
  function obj = EntityIteratorBase(impl)
    obj.impl = impl;
  end

  function result = hasNext(self)
    try
      result = self.impl.hasNext();
    catch e
      HandleException(e, 'AMPLAPI:Iterator:hasNext');
    end
  end

  function result = next(self)
    try
      if self.hasNext()
        entity = self.impl.next();
        if(isa(entity, 'com.ampl.Variable'))
            result = Variable(entity);
        elseif(isa(entity, 'com.ampl.Constraint'))
            result = Constraint(entity);
        elseif(isa(entity, 'com.ampl.Parameter'))
            result = Parameter(entity);
        elseif(isa(entity, 'com.ampl.Objective'))
            result = Objective(entity);
        elseif(isa(entity, 'com.ampl.Set'))
            result = Set(entity);
        else
            result = entity;
        end
      else
        result = []
      end
    catch e
      HandleException(e, 'AMPLAPI:Iterator:next');
    end
  end

  function result = toArray(self)
    try
      result = {};
      while self.hasNext()
        result{end+1} = self.next();
      end
    catch e
      HandleException(e, 'AMPLAPI:Iterator:toArray');
    end
  end

end
end
